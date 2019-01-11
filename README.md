# Meta CodePipeline

*Who deploys the deployers?*

A CodePipeline to wrap another CodePipeline, allowing Continuous Deployment of pipeline configuration updates.

Wait, what now?

We at [Symphonia](https://www.symphonia.io) are big fans of AWS, Continuous Deployment, and Infrastructure-as-Code. As such we use AWS CodePipeline and CodeBuild whenever we can. And we always define our CodePipeline definitions within a CloudFormation template. Which is great, but what happens when this template changes?

Typically what we do is have a manual process to update the CloudFormation Stack that holds the CodePipeline definition. But manual updating of infrastructure is so 20th century - wouldn't it better just to commit the changes for the CodePipeline template to source control, and have them automatically be deployed? In other words can we continuously deploy our continuous deployment?

Why yes, we can. Welcome to **Meta CodePipeline**!

Meta CodePipeline is a separate CodePipeline that wraps your application's CodePipeline. It uses the same source control repository as your application, but only updates when the application pipeline template itself is updated.

This pattern is especially useful at the beginning of a project when the structure of the application is changing.

## Prerequisites

This project assumes you're using GitHub as your source repository, and that you can create a GitHub personal access token with appropriate admin permissions for it. See [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) for how to create a token - CodePipeline needs just the `repo` scope permissions. I recommend you name the token for this particular pipeline, at least to get started, and that you store the token somewhere safe, like a password manager.

## How to use

:warning: **BIG WARNING:** as currently implemented this will create **ENTIRELY NEW** instances of your application CodePipeline, and therefore likely the application it deploys, depending on your setup. If you want to use an existing CodePipeline you'll need to modify the template in the "non SAR" version of usage, below.

### Serverless Application Repo (SAR) version

TODO - flesh this out a little more:

Meta CodePipeline is available in the AWS Serverless Application Repo [here](https://serverlessrepo.aws.amazon.com/#/applications/arn:aws:serverlessrepo:us-east-1:392967531616:applications~meta-codepipeline) . To use this as a SAR nested app, follow the instructions below.

Create your application's CodePipeline as normal, and save it to your's application's source repo.

Now create a new template (e.g. `meta-pipeline.yaml`) as follows:

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: my-meta-codepipeline
Transform: AWS::Serverless-2016-10-31

Parameters:
  # NoEcho set to true so that we aren't able to query this value
  GitHubOAuthToken:
    Type: String
    NoEcho: true
    MinLength: 40
    MaxLength: 40
    AllowedPattern: '[a-z0-9]*'

Resources:
  NestedMetaPipeline:
    Type: AWS::Serverless::Application
    Properties:
      Location:
        ApplicationId: arn:aws:serverlessrepo:us-east-1:392967531616:applications/meta-codepipeline
        SemanticVersion: 1.0.1
      Parameters: 
        GitHubOAuthToken: !Ref GitHubOAuthToken
        GitHubOwner: YOUR-GITHUB-OWNER
        GitHubRepo: YOUR-GITHUB-REPO
        GitHubBranch: YOUR-GITHUB-BRANCH (e.g. master)
        TargetPipelineStackName: YOUR-APPLICATION-CODEPIPELINE-STACK-NAME
        TargetPipelineTemplateName: YOUR-APPLICATION-CODEPIPELINE-TEMPLATE-FILE
```

Deploy this as follows - this will create your meta CodePipeline, which will create your application CodePipeline, which will create your application(s) . Substitute the name of your meta CodePipeline stack, and your GitHub repo :

```bash
aws cloudformation deploy \
        --template-file meta-pipeline.yaml \
        --stack-name **YOUR-META-CODEPIPELINE-STACK-NAME** \
        --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
        --parameter-overrides GitHubOAuthToken=**YOUR_GITHUB_OAUTH_TOKEN** \
```

### Non SAR version

TODO 


