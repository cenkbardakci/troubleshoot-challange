# Take Home Assignment for Deployment Engineer positions

### This exercise is to get a general feeling about the technical problems you have worked on and about how comfortable you are working in certain areas.

### It should ideally not take more than 1-4 hours of your time. Feel free to use any sources of information you like.

## 1. Review the following Dockerfile for broken things and general best practices:
```
FROM alpine
ENV POETRY_VERSION=1.1.13 \
HOME=/home/user \
PATH="${HOME}/.local/bin:${PATH}" \
PORT=8080
RUN addgroup user &&\
adduser -S -G user -h $HOME user &&\
apk add --no-cache \
curl \
python3-dev \
gcc \
libressl-dev \
musl-dev \
libffi-dev &&\
curl -sSL https://install.python-poetry.org |\
python3 - --version $POETRY_VERSION &&\
mkdir /home/user/.ssh
COPY app/ /app/
COPY ssh-keys/id_rsa /home/user/.ssh/id_rsa
RUN cd /app && poetry install --no-dev --no-root --no-interaction --no-ansi
USER user
ENTRYPOINT ["poetry", "run"]
CMD ["uvicorn", "--host=0.0.0.0", "--port=$PORT", "--workers=$UVICORN_WORKERS"]
```

### 1. Answer 

Answers are in the new [Dockerfile](https://github.com/cenkbardakci/troubleshoot-challange/blob/main/Dockerfile).

## 2. Question

You have one aws account with an ECR repository and another one with
an iam user.
The IAM user should be able to assume a role in the ecr aws account and
push docker images to the ecr repository.
Briefly outline the missing parts.

### 2. Answer 

IAM Rules are in [TF Json Example](https://github.com/cenkbardakci/troubleshoot-challange/blob/main/iam.tf)

## 3. Question

You have a service spread out over 4 ec2 instances.
The service requires a majority of instances to be available to function (so
3 instances in our case) and runs in the following aws availability zones:
- us-east-1a
- us-east-1b
- us-east-1c
- us-west-1a
What kind of possible problems do you see with that configuration?

### 3. Answer 

There are 3 important issues on this deployment strategy. 

### 1. Single Point of Failure
- **Single Point of Failure:** If we keep `us-west-1a` as 1 AZ, when an AZ outage happens, we lose the entire region.

### 2. Network Latency
- **Network Latency:** Networks are in different regions, so millisecond latencies will occur. While you could use **CloudFront** or **VPC peering**, why introduce extra services?

### 3. Regional Failure
- **Regional Failure:** If we lose the `us-east` region, then we only have 1 instance left, and the service will not run. This is another significant issue.

**Recommendation:** Create 4 AZs in the same region if the region’s AZ count matches. Additionally, establish another region with 4 AZs for redundancy. If your services support it, consider implementing an active-passive deployment.
 

## 4. Question

You have a kubernetes deployment for a backend. That backend is accessed
by clients through a kubernetes service:
```
apiVersion: v1
kind: Service
metadata:
name: my-service
spec:
selector:
app: my-service
ports:
- protocol: TCP
port: 443
targetPort: 9376
```
Over time, you notice that load on the backend pods skews. Some pods
have high load, others barely any at all.
What might be possible problems?

### 4. Answer

After you check situation of usage with this command

```
kubectl top nodes 
kubectl top pods
```

You can follow up these steps 

- Sticky Sessions (If client redirects same pod repetitively) Solution `sessionAffinity: None`
- Load Balancing IPtables vs IPVS (iptables offer round robbing IPVS is more sophisticated) Solution: `--proxy-mode=ipvs` after check the mode `kubectl describe configmap kube-proxy -n kube-system`
- Check Pods Resource Usage with kubectl top pods if pods are not balanced. 
- Readiness / Liveness Prod: check configs are correct and not too agressive. 



## 5. Question

You have a workload on kubernetes and notice that it looses too many
pods during kubernetes node updates.
How could you fix the problem or make it less bad?

### 5.Answer

To reduce the impact or prevent pod loss during the updates here is some strategies : 

- https://kubernetes.io/docs/concepts/scheduling-eviction/

- Pod Distrubiton Budget : Set percentage of pods always available during the update
```
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app1-pdb
spec:
  minAvailable: 80%  # At least 80% of the pods must remain available during updates
  selector:
    matchLabels:
      app: app1

```
- Max Unavailable : Set how many pods can be unavailable during the update .

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Only 1 pod can be unavailable during updates
      maxSurge: 2        # Allow 2 additional pods during updates to ensure capacity

```
- Anti-Affinity Rules : Ensure pods are spreading all different nodes during the update

```
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - my-app
        topologyKey: "kubernetes.io/hostname"
```



## 6. Question

Describe what a remote state backend does in terraform.

### 6. Answer

Remote Backend State is a file which keeps all configuration belongs to tf repo. After terraform apply command state file will be created in selected areas. We can keep our state file , Cloud Provider Buckets and Terraform Cloud. There are few advanteges keep our states as remote. 

- Centralized Storage: for collabration between devs to contribute at the same time. 
- Security: Encryption and versioning is secure your state file . 
- Pipeline Friendly: Your state file is adapt into the CI/CD pipelines and drift changes. 
- Concurrency and Lock: Set limits of concurrent changes of terraform files and keep consistent. (AWS has dynamo db lock)

## 7. Question

You are using a service that works 95% of the time.
Assuming you can replicate the service: how many replicas would you need
to reach 99% for all replicas combined (at least 1 online) ?

### 7. Answer 

I honestly gave the numbers to Copilot and the results on base cover %5 outage possiblity that meanse 0.05. If we assume that n replicas will be there and fail over scenarios for 1 replica or n replica included. Result is 2 and more relpica works perfect for %99 .


