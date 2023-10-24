include etc/environment.sh

sam: sam.package sam.deploy
sam.package:
	sam package -t ${SAM_TEMPLATE} --output-template-file ${SAM_OUTPUT} --s3-bucket ${BUCKET} --s3-prefix ${SAM_STACK}
sam.deploy:
	sam deploy -t ${SAM_OUTPUT} --stack-name ${SAM_STACK} --parameter-overrides ${SAM_PARAMS} --capabilities CAPABILITY_NAMED_IAM

local:
	sam local invoke -t ${SAM_TEMPLATE} --parameter-overrides ${SAM_PARAMS} --env-vars etc/envvars.json -e etc/event.json Fn | jq
lambda.invoke.sync:
	aws --profile ${PROFILE} lambda invoke --function-name ${O_FN} --invocation-type RequestResponse --payload file://etc/event.json --cli-binary-format raw-in-base64-out --log-type Tail tmp/fn.json | jq "." > tmp/response.json
	cat tmp/response.json | jq -r ".LogResult" | base64 --decode
	cat tmp/fn.json | jq
lambda.invoke.async:
	aws --profile ${PROFILE} lambda invoke --function-name ${O_FN} --invocation-type Event --payload file://etc/event.json --cli-binary-format raw-in-base64-out --log-type Tail tmp/fn.json | jq "."

sf.invoke:
	aws --profile ${PROFILE} stepfunctions start-execution --state-machine-arn ${O_SF} --input file://etc/event.json | jq
sf.list-executions:
	aws --profile ${PROFILE} stepfunctions list-executions --state-machine-arn ${O_SF} | jq
