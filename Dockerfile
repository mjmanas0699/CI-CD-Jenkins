FROM python:slim

WORKDIR /app

COPY app/ .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD ["python","/app/app.py"]