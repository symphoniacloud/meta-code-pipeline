#!/bin/bash

# This is for Symphonia use only - how we publish new versions of this SAR app to SAR itself

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

sam package --template-file template.yaml --output-template-file packaged.yaml --s3-bucket "cloudformation-artifacts-$ACCOUNT_ID-us-east-1"
sam publish --region us-east-1 --template packaged.yaml

