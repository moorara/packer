[![Build Status][workflow-image]][workflow-url]

# Packer

This is a [Packer](https://packer.io) project for building pre-configured images.
These images can be used for provisioning nodes in misc cloud platforms.

## Available Images

| Image        | AWS  | Azure | Google Cloud |
|--------------|:----:|:-----:|:------------:|
| CentOS 7     |  ✓   |       |  ✓           |
| Debian 9     |  ✓   |       |  ✓           |
| Fedora 29    |  ✓   |       |              |
| Ubuntu 16.04 |  ✓   |       |  ✓           |

## Configurations

### Prerequisites

You need to have [Packer](https://packer.io) and [Terraform](https://terraform.io) installed.

### AWS

For building Amazon machine images, you need to have an `aws.json` file in the root of project.
You should set the following fields in this file.

```json
{
  "aws_access_key": "",
  "aws_secret_key": "",
  "aws_vpc_id": "",
  "aws_subnet_id": ""
}
```

If you have a default VPC, Packer will use that for building images by default.
If you want to use the default VPC, you can leave out `aws_vpc_id` and `aws_subnet_id` fields.
If you have deleted your default VPC or you want Packer to use a different VPC, you need to create a new VPC.
Make sure that the new VPC has access to internet and is reachable from internet at port `22` (ssh access).

For creating a new _AWS IAM_ user, follow these steps:

  1. Navigate to **IAM** service.
  1. Click on **Users**.
  1. Click on **Add user**, choose a **User name** and select **Programmatic access**.
  1. Click on **Next: Permissions** and set required permissions (assign to a group or attach policies).
  1. Click on **Next: Tags** and any tag if you need.
  1. Click on **Next: Review**.
  1. Click on **Create user** and record **Access key ID** and **Secret access key**.

### Google Cloud

For building Google Cloud images, you need two files in the root of project.
You should set the following fields in `google.json` file.

```json
{
  "google_project_id": "",
  "google_network": "",
  "google_subnetwork": ""
}
```

If you have a default VPC network in your region, Packer will use that for building images by default.
If you want to use the default VPC network, you can leave out `google_network` and `google_subnetwork` fields.
If you want Packer to use a different VPC network, you need to create a new VPC network.

You also need an `account.json` file.
You can get this file from Google Cloud Platform console.

  1. Navigate to **IAM & admin** and then **Service accounts**.
  1. Click on **CREATE SERVICE ACCOUNT**.
  1. Enter a name (_Service account name_) and click on **CREATE**.
  1. Select `Project > Editor` for **Role** and click on **CONTINUE**.
  1. On next page, click on **CREATE KEY**, select `JSON`, and click on **CREATE**.
  1. Download the file and rename it to `account.json`.
  1. Click on **DONE**.

## Building Images

You can build images using the following commands.

| All Platforms | AWS                         | Google Cloud                   |
|---------------|-----------------------------|--------------------------------|
| `make centos` | `make centos platforms=aws` | `make centos platforms=google` |
| `make debian` | `make debian platforms=aws` | `make debian platforms=google` |
| `make fedora` | `make fedora platforms=aws` |                                |
| `make ubuntu` | `make ubuntu platforms=aws` | `make ubuntu platforms=google` |

### Updating Images

If you want to update the base image for any of the available images,
change the `aws_source_ami` or `google_source_image` property in `variables` section of the image `json` file.

## Running Tests

Each image comes with a set of tests. These tests are command-based.
A new instance is spun up using [Terraform](https://www.packer.io).
Then, the given commands are run through `ssh`, and a set of regexes are tested against the output.

You can run the tests as follows.

```
make centos-test
make debian-test
make fedora-test
make ubuntu-test
```

Here is a screenshot of test results:

![test-screenshot](./images/test-screenshot.png "test-screenshot")


[workflow-url]: https://github.com/moorara/packer/actions
[workflow-image]: https://github.com/moorara/packer/workflows/Main/badge.svg
