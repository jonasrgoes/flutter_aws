import os
import json
import boto3
import locale

from decimal import Decimal

from botocore.exceptions import ClientError
from botocore.exceptions import BotoCoreError

from boto3.dynamodb.conditions import Key

from aws_lambda_powertools.tracing import Tracer
from aws_lambda_powertools.logging.logger import Logger
from aws_lambda_powertools import Metrics
from aws_lambda_powertools.metrics import MetricUnit

locale.setlocale(locale.LC_ALL, "pt_BR")

dynamodb = boto3.resource("dynamodb")
tbl_expenses = dynamodb.Table(os.environ["EXPENSES_TABLE"])

logger = Logger()
tracer = Tracer()
metrics = Metrics(namespace="FLUTTER_AWS")


@metrics.log_metrics(raise_on_empty_metrics=False, capture_cold_start_metric=True)
@logger.inject_lambda_context
@tracer.capture_lambda_handler
def lambda_handler(event, context):

    try:

        data = json.loads(json.dumps(event))

        email = data["email"]

        metrics.add_dimension(name="environment", value=os.environ["STAGE"])

        logger.structure_logs(append=True, title="LIST ALL EXPENSES")

        total = sum(email)

        return {"statusCode": 200, "body": "SUCCESS", "total": total}

    except Exception as e:
        metrics.add_metric(name="FAILED", unit=MetricUnit.Count, value=1)

        tracer.put_annotation("STATUS", "Exception Raised")

        logger.error({"operation": "Failed", "details": e})

        return {"statusCode": 500, "body": "FAILED", "event": event, "error": str(e)}


@tracer.capture_method
def sum(email):

    total = 0

    try:
        query = tbl_expenses.query(
            IndexName="emailAndDate",
            Select="ALL_ATTRIBUTES",
            KeyConditionExpression=Key("email").eq(email),
            ScanIndexForward=False,
        )

        items = query["Items"]

        for item in items:
            total += Decimal(item["value"])

        return total

    except (BotoCoreError, ClientError) as e:
        metrics.add_metric(name="BOTO3_ERROR", unit=MetricUnit.Count, value=1)
        logger.error(e)
        raise Exception(e)
    except Exception as e:
        logger.error(e)
        raise Exception(e)
