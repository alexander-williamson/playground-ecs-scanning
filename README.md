# playground-ecs-scanning
A demo app that scans and reports scan results to an EventBridge Rule and on to a topic.

We did not get the worker running that listened to the events yet (timeboxed spike).

What you can do:
- Setup infrastructure
  - Creates an ECR repository you can push to
- Build and push a docker image to the ECR image
- Scripts to download the docker image, tag it and push it to Snowflake 

## Steps

### 1. Enable the shell scripts to be executed in your terminal:

```bash
chmod +x ./01_infrastructure.sh
chmod +x ./02_push_docker_image.sh
chmod +x ./03_push_to_snowflake.sh
```

Deploy the infrastructure (uses terraform). You'll need to be running under an aws role with enough creds to create the necessary components:

```bash
awsume sdp-dev
./01_infrastructure.sh
```

### 2. Build, tag and push a container image to ECR:

- First update the SEMVER variable in `02_push_docker_image.sh`
```
SEMVER=1.0.2
(... the rest of 02_push_docker_image.sh here)
```
- Then run the `02_push_docker_image` shell script to tag (your semver) and push the image. You'll need to be awsume'd into a role with enough creds to push to ECR:

```bash
awsume sdp-dev

./02_push_docker_image.sh
```

### 3. Download the docker image, tag it again for Snowflake and push it to snowflake.

- First update the SEMVER variable in `02_push_docker_image.sh`
```
SEMVER=1.0.2
(... the rest of 03_push_to_snowflake.sh here)
```
- Then run the `03_push_to_snowflake.sh` shell script to tag (your semver) and push the image. You need `snow cli` for this to work:

```bash
awsume sdp-dev

03_push_to_snowflake.sh
```

### 4. Create the Snowflake Service and use the image

In Snowflake:

```sql
CREATE SERVICE <name> FROM SPECIFICATION <specification>;
-- or
ALTER SERVICE <name> FROM SPECIFICATION <specification>;
-- or 
DROP SERVICE
```

```snowflake
CREATE SERVICE echo_service
IN COMPUTE POOL TUTORIAL_COMPUTE_POOL
FROM SPECIFICATION $$
spec:
 containers:
 - name: example
   image: /tutorial_db/alex_test_data_schema/tutorial_repository/test-ecs-scanning-demo-basic-image-scanning:1.0.8
   readinessProbe:
     port: 3000
     path: /
 endpoints:
  - name: publicendpoint
    port: 3000
    public: true
$$;
```

After a few mintes you'll have an endpoint. If you drop the service and recreate it you'll get a new endpoint, so use the ALTER syntax to update the service and container versions.