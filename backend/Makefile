upgrade:
	brew upgrade aws-sam-cli

newlayer:
	aws lambda publish-layer-version \
    --layer-name BS4 \
    --region 'us-east-1' \
    --description 'Beautiful Soup 4' \
    --zip-file fileb://python.zip \
    --compatible-runtimes 'python3.8'

create-bucket:
	aws s3 mb s3://dev-jonasrgoes --region us-east-1

create-stack:
	aws cloudformation create-stack --stack-name flutter-aws --template-url template.yaml

build:
	sam build

package:
	sam package --template template.yaml --output-template-file cloudformation.yaml --s3-prefix flutter-aws --s3-bucket dev-jonasrgoes --region us-east-1

deploy: build package
	aws cloudformation deploy --template-file cloudformation.yaml --stack-name flutter-aws --region us-east-1 --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND

validate:
	# aws cloudformation validate-template --template-url INSERT_TEMPLATE_URL_HERE
	sam validate

describe:
	aws cloudformation describe-stack-events --stack-name flutter-aws

start-api:
	sam local start-api

delete:
	aws cloudformation delete-stack --stack-name flutter-aws

addlogs:
	sam logs --stack-name flutter-aws --name AddExpenseFunction --tail

listlogs:
	sam logs --stack-name flutter-aws --name ListExpensesFunction --tail
