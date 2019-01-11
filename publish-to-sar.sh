#!/bin/sh

# This is for Symphonia use only - how we publish new versions of this SAR app to SAR itself

sam package --template-file template.yaml --output-template-file packaged.yaml --s3-bucket meta-code-pipeline-sar-package
sam publish --region us-east-1 --template packaged.yaml

