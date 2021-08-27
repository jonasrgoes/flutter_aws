import os
import boto3
import locale

from botocore.exceptions import ClientError
from botocore.exceptions import BotoCoreError

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
        metrics.add_dimension(name="environment", value=os.environ["STAGE"])

        logger.structure_logs(append=True, title="LIST ALL EXPENSES")

        items = list()

        return {"statusCode": 200, "body": "SUCCESS", "items": items}

    except Exception as e:
        metrics.add_metric(name="FAILED", unit=MetricUnit.Count, value=1)

        tracer.put_annotation("STATUS", "Exception Raised")

        logger.error({"operation": "Failed", "details": e})

        return {"statusCode": 500, "body": "FAILED", "event": event, "error": str(e)}


@tracer.capture_method
def list():

    try:
        query = tbl_expenses.scan()

        items = query["Items"]

        return items

    except (BotoCoreError, ClientError) as e:
        metrics.add_metric(name="BOTO3_ERROR", unit=MetricUnit.Count, value=1)
        logger.error(e)
        raise Exception(e)
    except Exception as e:
        logger.error(e)
        raise Exception(e)
