<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS Inspector
</h1>

<p align="center" style="font-size: 1.2rem;">
    Terraform module to create Inspector on AWS for monitoring instances.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.12-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/clouddrove/terraform-aws-secure-baseline/modules/inspector'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+Inspector&url=https://github.com/clouddrove/clouddrove/terraform-aws-secure-baseline/modules/inspector'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+Inspector&url=https://github.com/clouddrove/clouddrove/terraform-aws-secure-baseline/modules/inspector'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure.

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies:

- [Terraform 0.12](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/clouddrove/terraform-aws-secure-baseline/modules/inspector/releases).


### Simple Example
Here is an example of how you can use this module in your inventory structure:
  ```hcl
  module "aws-inspector" {
    source              = "./../"
    name                = "aws-inspector"
    application         = "clouddrove"
    environment         = "test"
    label_order         = ["environment", "application", "name"]
    enabled             = true
    instance_tags       = {
        "Inspector" = true
    }
    inspector_enabled   = true
    duration            = 300
    rules_package_arns  = [
      "arn:aws:inspector:eu-west-1:357557129151:rulespackage/0-ubA5XvBh",
      "arn:aws:inspector:eu-west-1:357557129151:rulespackage/0-sJBhCr0F",
      "arn:aws:inspector:eu-west-1:357557129151:rulespackage/0-SPzU33xe",
      "arn:aws:inspector:eu-west-1:357557129151:rulespackage/0-SnojL3Z6",
    ]
    lambda_enabled      = true
    schedule_expression = "cron(0/10 * ? * MON-FRI *)"
    handler             = "index.handler"
    runtime             = "nodejs12.x"
    statement_ids       = ["AllowExecutionFromEvents"]
    actions             = ["lambda:InvokeFunction"]
    principals          = ["events.amazonaws.com"]
    iam_actions = [
      "inspector:StartAssessmentRun",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
  ```
**Note:** We have to install agent in every instances which need to be inspect by AWS Inspector.






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| actions | The AWS Lambda action you want to allow in this statement. (e.g. lambda:InvokeFunction). | list(string) | `<list>` | no |
| application | Application (e.g. `cd` or `clouddrove`). | string | `` | no |
| duration | The duration of the inspector run. | number | `3600` | no |
| enabled | Flag to control the module creation. | bool | `false` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | string | `` | no |
| handler | The function entrypoint in your code. | string | `` | no |
| iam_actions | The actions for Iam Role Policy. | list | `<list>` | no |
| instance_tags | Instance tags. | map | `<map>` | no |
| is_enabled | Whether the rule should be enabled (defaults to true). | bool | `true` | no |
| kms_key_id | The ARN for the KMS encryption key. When specifying kms_key_id, encrypted needs to be set to true. | string | `` | no |
| label_order | Label order, e.g. `name`,`application`. | list | `<list>` | no |
| lambda_enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources. | bool | `true` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | string | `anmol@clouddrove.com` | no |
| name | Name  (e.g. `app` or `cluster`). | string | `` | no |
| principals | The principal who is getting this permission. e.g. s3.amazonaws.com, an AWS account ID, or any valid AWS service principal such as events.amazonaws.com or sns.amazonaws.com. | list(string) | `<list>` | no |
| rule_iam_role_arn | The Amazon Resource Name (ARN) associated with the role that is used for target invocation. | string | `` | no |
| rules_package_arns | The rules to be used during the run. | list(string) | `<list>` | no |
| runtime | Runtimes. | string | `` | no |
| schedule_expression | AWS Schedule Expression: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html | string | `cron(0 14 ? * THU *)` | no |
| statement_ids | A unique statement identifier. By default generated by Terraform. | list(string) | `<list>` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | map | `<map>` | no |
| target_iam_role_arn | The Amazon Resource Name (ARN) associated with the role that is used for target invocation. | string | `` | no |
| timeout | The amount of time your Lambda Function has to run in seconds. Defaults to 3. | number | `120` | no |

## Outputs

| Name | Description |
|------|-------------|
| assessment_target | The target assessment ARN. |
| assessment_template | The template assessment ARN. |
| lambda_arn | The Amazon Resource Name (ARN) identifying your Lambda Function. |
| resource_group | The resource group ARN. |
| tags | The tags of aws inspector. |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system.

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/clouddrove/terraform-aws-secure-baseline/modules/inspector/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/clouddrove/terraform-aws-secure-baseline/modules/inspector)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
