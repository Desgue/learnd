FROM public.ecr.aws/lambda/python:3.9

COPY requirements.txt ./

RUN python3.9 -m pip install -r requirements.txt -t .

COPY processor.py ./

CMD ["processor.lambda_handler"]