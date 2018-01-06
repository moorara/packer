# cloud-images
This is a [Packer](https://www.packer.io) project for building pre-configured images.
These images can be used for provisioning nodes in misc cloud platforms.

## Available Images
| Image | AWS  | Azure | Google Cloud |
|-------|:----:|:-----:|:------------:|

## Configurations

### AWS
For building Amazon machine images, you need to have an `aws.json` file in the root of project.
You should set the following fields in this file.

```json
{
  "aws_access_key":  "",
  "aws_secret_key":  "",
  "aws_vpc_id":      "",
  "aws_subnet_id":   ""
}
```

If you have a default VPC, Packer will use that for building images by default.
If you want to use the default VPC, you can leave out `aws_vpc_id` and `aws_subnet_id` fields.
If you have deleted your default VPC or you want Packer to use a different VPC, you need to create a new VPC.
Make sure that the new VPC has access to internet and is reachable from internet at port `22` (ssh access).

### Google Cloud
For building Google Cloud images, you need two files in the root of project.
You should set the following fields in `google.json` file.

```json
{
  "google_project_id":  "",
  "google_network":     "",
  "google_subnetwork":  ""
}
```

If you have a default VPC network in your region, Packer will use that for building images by default.
If you want to use the default VPC network, you can leave out `google_network` and `google_subnetwork` fields.
If you want Packer to use a different VPC network, you need to create a new VPC network.

You also need an `account.json` file.
You can get this file from Google Cloud Platform console.

  1. Go to `IAM & admin > Service accounts`.
  2. Click on `Create service account`.
  3. Enter a name and select `Project > Editor` for *Role*.
  4. Check `Furnish a new private key` and select `JSON`.
  5. Click on `CREATE` button, download the file, rename it to `account.json`.
