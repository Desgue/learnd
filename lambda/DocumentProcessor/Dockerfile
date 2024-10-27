FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt ./

RUN python -m pip install -r requirements.txt -t .

COPY processor.py ./

CMD ["processor.lambda_handler"]