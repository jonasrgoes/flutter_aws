import os
import json
import boto3
import locale

from datetime import datetime
from decimal import Decimal

from botocore.exceptions import ClientError
from botocore.exceptions import BotoCoreError

from aws_lambda_powertools.tracing import Tracer
from aws_lambda_powertools.logging.logger import Logger
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

locale.setlocale(locale.LC_ALL, "pt_BR")

dynamodb = boto3.resource("dynamodb")
tbl_expenses = dynamodb.Table(os.environ["EXPENSES_TABLE"])

ses = boto3.client("ses", region_name=os.environ["CURRENT_AWS_REGION"])

logger = Logger()
tracer = Tracer()
metrics = Metrics(namespace="FLUTTER_AWS")


@metrics.log_metrics(raise_on_empty_metrics=False, capture_cold_start_metric=True)
@logger.inject_lambda_context
@tracer.capture_lambda_handler
def lambda_handler(event, context):

    try:

        data = json.loads(json.dumps(event), parse_float=Decimal)

        now = datetime.now()

        email = data["email"]
        value = data["value"]
        date = now.strftime("%Y-%m-%dT%H:%M:%SZ")

        metrics.add_dimension(name="environment", value=os.environ["STAGE"])

        logger.structure_logs(append=True, title=email)

        tracer.put_metadata("email", email)
        tracer.put_metadata("value", value)
        tracer.put_metadata("date", date)

        insert(email, value, date)

        metrics.add_metric(name="ADDED NEW EXPENSE", unit=MetricUnit.Count, value=1)

        tracer.put_annotation("STATUS", "CONFIRMED")

        return {"statusCode": 200, "body": "SUCCESS", "event": event}

    except Exception as e:
        metrics.add_metric(name="FAILED", unit=MetricUnit.Count, value=1)

        tracer.put_annotation("STATUS", "Exception Raised")

        logger.error({"operation": "Failed", "details": e})

        return {"statusCode": 500, "body": "FAILED", "event": event, "error": str(e)}


@tracer.capture_method
def insert(email, value, date):

    try:
        tbl_expenses.put_item(
            Item={"email": email, "value": value, "date": date},
            ExpressionAttributeNames={"#E": "email", "#D": "date"},
            ConditionExpression="attribute_not_exists(#E) And attribute_not_exists(#D)",
        )
    except (BotoCoreError, ClientError) as e:
        metrics.add_metric(name="BOTO3_ERROR", unit=MetricUnit.Count, value=1)
        logger.error(e)
        raise Exception(e)
    except Exception as e:
        logger.error(e)
        raise Exception(e)
