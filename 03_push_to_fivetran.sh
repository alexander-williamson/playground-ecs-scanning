SEMVER=1.0.12
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_REGION_ID="eu-west-1"
IMAGE=test-ecs-scanning-demo-basic-image-scanning
ECR=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION_ID.amazonaws.com

# login to ecr
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $ECR

# download the image
docker pull $ECR/$IMAGE:$SEMVER

# login to snowflake
# TODO how to automate in this shell script (so do it beforehand)
snow spcs image-registry login

# tag the image so it can be pushed
SNOWFLAKE_TAG=bbcstudios-bbcstudios-test.registry.snowflakecomputing.com/tutorial_db/alex_test_data_schema/tutorial_repository/$IMAGE:$SEMVER
echo $SNOWFLAKE_TAG
docker image tag $ECR/$IMAGE:$SEMVER $SNOWFLAKE_TAG

# push to snowflake
docker push $SNOWFLAKE_TAG

