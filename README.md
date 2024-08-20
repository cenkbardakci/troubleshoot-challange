#Take Home Assignment for Deployment Engineer positions

This exercise is to get a general feeling about the technical problems you have
worked on and about how comfortable you are working in certain areas.

It should ideally not take more than 1-4 hours of your time. Feel free to use any
sources of information you like.

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

## 2. You have one aws account with an ECR repository and another one with
an iam user.
The IAM user should be able to assume a role in the ecr aws account and
push docker images to the ecr repository.
Briefly outline the missing parts.
## 3. You have a service spread out over 4 ec2 instances.
The service requires a majority of instances to be available to function (so
3 instances in our case) and runs in the following aws availability zones:
- us-east-1a
- us-east-1b
- us-east-1c
- us-west-1a
What kind of possible problems do you see with that configuration?

## 4. You have a kubernetes deployment for a backend. That backend is accessed
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

## 5. You have a workload on kubernetes and notice that it looses too many
pods during kubernetes node updates.
How could you fix the problem or make it less bad?
## 6. Describe what a remote state backend does in terraform.
## 7. You are using a service that works 95% of the time.
Assuming you can replicate the service: how many replicas would you need
to reach 99% for all replicas combined (at least 1 online) ?