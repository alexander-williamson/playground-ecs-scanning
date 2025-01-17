SEMVER=1.0.15
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_REGION_ID="eu-west-1"
IMAGE=test-ecs-scanning-demo-basic-image-scanning
ECR=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION_ID.amazonaws.com
LONG_TAG=$ECR/$IMAGE

# build the docker image
(cd app && docker build --rm --platform linux/amd64 -t "${LONG_TAG}:$SEMVER" -t "${LONG_TAG}:latest" .)

# login to AWS ECR
# aws ecr get-login-password --region $AWS_REGION_ID | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ECR

# push the build image
docker push "${LONG_TAG}:$SEMVER"

# wait for the scan to complete (we think this only works for a Basic Scan for now) (cannot be done if continuous scan enabled in Basic or Enhanced)
# aws ecr wait image-scan-complete --repository-name $IMAGE --image-id imageTag=$SEMVER

# describe the findings
aws ecr describe-image-scan-findings --image-id imageTag=$SEMVER --registry-id $AWS_ACCOUNT_ID --repository-name test-ecs-scanning-demo-basic-image-scanning

# poll for imageScanStatus status to be ACTIVE (enhanced needs ACTIVE, basic needs COMPLETE)
# there is an ecr wait command but it's understood to not work because it waits for ACTIVE
command_to_run="aws ecr describe-image-scan-findings --image-id imageTag=$SEMVER --registry-id $AWS_ACCOUNT_ID --repository-name test-ecs-scanning-demo-basic-image-scanning"
json_key=".imageScanStatus.status"
desired_value="ACTIVE"
interval_in_seconds=5
timeout=120
start_time=$(date +%s)
while true; do
    # Run the command and capture the output
    output=$($command_to_run)
    # Extract the value from the JSON output
    value=$(echo $output | jq -r "$json_key")
    # Check if the value matches the desired value
    if [ "$value" == "$desired_value" ]; then
        echo "Condition met: $json_key is $desired_value"
        break
    else
        echo "Condition not met yet: $json_key is $value"
    fi
    # Check if the timeout has been reached
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ $elapsed_time -ge $timeout ]; then
        echo "Timeout reached after $timeout seconds"
        exit 1
    fi
    # Wait for the specified interval before checking again
    sleep $interval_in_seconds
done
