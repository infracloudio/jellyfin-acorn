# Deploying Jellyfin on Acorn

[Jellyfin](https://jellyfin.org/) is the volunteer-built media solution that puts you in control of your media. Stream to any device from your own server, with no strings attached. Your media, your server, your way.

Jellyfin is a popular media server solution, valued for its open-source nature and robust features that empower users to manage and stream their media content seamlessly. When deployed on [Acorn](http://www.acorn.io) platform offering a generous free sandbox accessible to all through GitHub registration, Jellyfin gains distinct advantages. To deploy an application on Acorn we need to define our application as an [Acornfile](https://docs.acorn.io/reference/acornfile), which will produce the Acorn Image that we can deploy on the platform.  In this tutorial, we will explore how to provision a sample Jellyfin Server on Acorn.

We will be deploying Jellyfin in conjuction with [Wasabi](https://wasabi.com/hot-cloud-storage/),one of the most affordable online storage options available. You can store all of your media on it with as little as $6.99 TB/Month, with no egress charges. 

To start using the application, you need to create your own Wasabi S3 bucket by registering to Wasabi. Once signed in, populate the Wasabi S3 bucket with your favourite Photos, Movies or Videos and generate Access Credentials. We will be using these credentials to connect to Jellyfin to download the Media using [Rclone](https://rclone.org/). We have two Rclone Jobs : rclone-init: to perform one-time initial sync of Jellyfin with Wasabi S3 and rclone-cronjob: runs as a scheduled cronjob for periodic Data Sync from the Wasabi S3 bucket and Jellyfn Media volume with default cron schedule of every 6hrs.

If you want to skip to the end, just click below to launch the app immediately in a free sandbox environment. All you need is a GitHub ID to create an account and provide Wasabi S3 configs in Advanced Configurations.

[Run in Acorn](https://acorn.io/run/ghcr.io/infracloudio/jellyfin-acorn:v10.%23.%23-%23?ref=slayer321&name=jellyfin)

If you want to follow along, I’ll walk through the steps to deploy Jellyfin using Acorn.

_Note: Everything shown in this tutorial can be found in [this repository](https://github.com/infracloudio/jellyfin-acorn)_.

## Pre-requisites

- Acorn CLI: The CLI allows you to interact with the Acorn Runtime as well as Acorn to deploy and manage your applications. Refer to the [Installation documentation](https://docs.acorn.io/installation/installing) to install Acorn CLI for your environment.
- A GitHub account is required to sign up and use the Acorn Platform.

## Acorn Login

Log in to the [Acorn Platform](https://acorn.io) using the GitHub Sign-In option with your GitHub user.

![Login Page](./assets/acorn-login-page.png)

After the installation of Acorn CLI for your OS, you can login to the Acorn platform.

```sh
$ acorn login
```


## Deploying the Jellyfin Application
In this tutorial we will deploy Jellyfin.

In the Acorn platform, there are two ways you can try this sample application.
1. Using Acorn platform dashboard.
2. Using CLI

Using Acorn Cloud Platform is the quickest and easiest way, where in just a few clicks, you can deploy the jellyfin application on the platform and start using it. However, if you want to customize the application, you can use the Acorn CLI.

## Deploying Using Acorn Dashboard

We will be using the published Acorn application image to deploy the Jellyfin application in just a few clicks. It allows you to deploy your applications faster without any additional configurations. Let us see below how you can deploy Jellyfin app to the Acorn platform dashboard.

1. Log in to the [Acorn Platform](https://acorn.io/auth/login)  using the GitHub Sign-In option with your GitHub user.
2. Select the “Create Acorn” option.
3. Choose the source for deploying your Acorns
   3.1. Select “From Acorn Image” to deploy the sample Application.
![](./assets/select-from-acorn-image.png)

   3.2. Provide a name "jellyfin”, use the default Region and provide the URL for the Acorn image and turn on the advanced option to provide the s3 bucket details where you have your media.
   ```
   ghcr.io/infracloudio/jellyfin-acorn:v10.#.#-#
   ```
![](./assets/jellyfin-deploy-preview.png)

_Note: The App will be deployed in the Acorn Sandbox Environment. As the App is provisioned on AcornPlatform in the sandbox environment it will only be available for 2 hrs and after that it will be shutdown. Upgrade to a pro account to keep it running longer_.

4. Once the Acorn is running, you can access it by clicking the Endpoint or the redirect link.
   4.1. Running Application on Acorn
   ![](./assets/jellyfin-platform-dashboard.png)
   4.2. Running Jellyfin
   ![](./assets/jellyfin-dashboard.png)


## Deploying Using Acorn CLI
As mentioned previously, running the acorn application using CLI lets you understand the Acornfile. With the CLI option, you can customize the sample app to your requirement or use your Acorn knowledge to run your own Jellyfin application.

To run the application using CLI you first need to clone the source code repository on your machine.

```
$ git clone https://github.com/infracloudio/jellyfin-acorn.git
```
Once cloned here’s how the directory structure will look.

```
.
├── Acornfile
├── rclone-config-script.sh
├── jellyfin.svg
├── LICENSE
└── README.md
```

### Understanding the Acornfile

We have the Jellyfin Application ready. Now to run the application we need an Acornfile which describes the whole application without all of the boilerplate of Kubernetes YAML files. The Acorn CLI is used to build, deploy, and operate Acorn on the Acorn cloud platform.

Below is the Acornfile for deploying the Jellyfin app that we created earlier:

```
args: {
	// Optional: Jellyfin media volume size
	storage:      "2G"
	// Required: Wasabi bucket name
	bucket_name:  ""
	// Required: Wasabi bucket region. Default: us-east-1
	region:       "us-east-1"
	// Required: Wasabi bucket url. Default: s3.wasabisys.com
	endpoint_url: "s3.wasabisys.com"
	// Required: Wasabi access key
	access_key:      ""
	// Required: Wasabi secret key
	secret_key:      ""
	// Optional: Bucket sync job cron schedule. Default: every 6 hours.
  rclone_schedule: "0 */6 * * *"
}

containers: {
	jellyfin: {
		image: "jellyfin/jellyfin:10.8.13"
		ports: publish: "8096:8096/http"
		env: {
			JELLYFIN_PublishedServerUrl: "@{services.jellyfin.endpoint}"
		}
		dirs: {
			"/config":        "volume://jellyfinconfig?subpath=config"
			"/cache":         "volume://jellyfinconfig?subpath=cache"
			"/jellyfinmedia": "volume://jellyfinmedia"
		}
	}
}

jobs: {
  "rclone-init": {
      image: "rclone/rclone:latest"
      env: {
        RCLONE_CONFIG_MYS3_TYPE: "s3"
        AWS_ACCESS_KEY_ID:       args.access_key
        AWS_SECRET_ACCESS_KEY:   args.secret_key
        AWS_S3_BUCKET:           args.bucket_name
				REGION:                  args.region
				ENDPOINT_URL: 				   args.endpoint_url
      }
      dirs: {
        "./rclone-config-script.sh": "./rclone-config-script.sh"
        "/jellyfinmedia": "volume://jellyfinmedia"
      }
      entrypoint: ["/bin/sh", "-c", "./rclone-config-script.sh"]
  }
  "rclone-cronjob": {
      image: "rclone/rclone:latest"
      env: {
        RCLONE_CONFIG_MYS3_TYPE: "s3"
        AWS_ACCESS_KEY_ID:       args.access_key
        AWS_SECRET_ACCESS_KEY:   args.secret_key
        AWS_S3_BUCKET:           args.bucket_name
				REGION:                  args.region
				ENDPOINT_URL: 				   args.endpoint_url
      }
      dirs: {
        "./rclone-config-script.sh": "./rclone-config-script.sh"
        "/jellyfinmedia": "volume://jellyfinmedia"
      }
      entrypoint: ["/bin/sh", "-c", "./rclone-config-script.sh"]
      schedule: args.rclone_schedule
  }
}

volumes: {
	jellyfinconfig: {
		size: 1G
	}
	jellyfinmedia: {
		size: args.storage
	}
}
```


We require below 2 components for running Jellyfin:
- Jellyfin app
- rclone jobs : init-job and periodic-job

The above Acornfile has the following elements:

- **Args**: Required and Optional User Arguments for running Jellyfin 
  - **storage**: Optional: Jellyfin media volume size. Default Value : 2G
  - **bucket_name**: Required: Wasabi bucket name
  - **region**: Required: Wasabi bucket region. Default: us-east-1
  - **endpoint_url**: Required: Wasabi bucket url. Default: s3.wasabisys.com
  - **access_key**: Required: Wasabi access key
  - **secret_key**: Required: Wasabi secret key
  - **rclone_schedule**: Optional: Rclone Cron Job schedule to periodically sync the Wasabi S3 bucket with Jellyfin Media Volume. Default: every 6 hours.
- **Containers**: We define the Jellyfinserver container with following configurations:
  - **jellyfin**:
    - **scale**: Jellyfin Replicas
    - **image**: It defines Jellyfin image
    - **ports**: ports required by the application.
    - **env**: Environment variables for running the Jellyfin server.
    - **dirs**: config, cache and Jellyfin Media mounts for the app.
- **Jobs**: 
  - **rclone-init**: Rclone Job for initial Data Sync from the Wasabi S3 bucket and Jellyfin Media volume.
    - **image**: Rclone image
    - **env**: Environment variables for running the Jellyfin.
    - **dirs**: Rclone script to create rclone configs for wasabi s3 sync and Jellyfin Media Volume mount.
    - **entrypoint**: Run the config script on container start.
  - **rclone-cronjob**: Rclone Cron Job for periodic Data Sync from the Wasabi S3 bucket and Jellyfn Media volume with default cron schedule of every 6hrs. 
- **Volumes**: Volumes to store persistent data in your applications

### Running the Application
We have already logged in using Acorn CLI now you can directly deploy applications on your sandbox on the Acorn platform. Run the following command from the root of the directory.

```
$ acorn run -n jellyfin . --access_key <>  --bucket_name <> --secret_key <>
```

Below is what the output looks like.

![](./assets/jellyfin-local-run.png)


## Jellyfin Application

In this tutorial till now we show how we can deploy our jellyfin server with our media content on s3 bucket by providing all the details. 

Once we provide all the login details and when selecting the folder select it as `/jellyfinmedia` as that's where we have copied the s3 media. Below is what our jellyfin dashboard looks like once we have everything running.You can see all the four photos that I have on s3 bucket.

![](./assets/jellyfin-dashboard.png)

If you are looking to host your local media to jellyfin you just need to make some minor changes to acornfile and run it using acorn cli from your local system.You need to remove two fields, first is the whole `sidecars` field and then the `bucketsync` field inside the current acornfile.Now replace the `/jellyfinmedia` field with your local directory. Currently if looks like `"/jellyfinmedia": "volume://jellyfinmedia"` change it to `"/jellyfinmedia": "./your/localmedia/path"`.


## What's Next?

1. The App is provisioned on Acorn Platform and is available for two hours. Upgrade to Pro account for anything you want to keep running longer.
2. After deploying you can edit the Acorn Application or remove it if no longer needed. Click the Edit option to edit your Acorn's Image. Toggle the Advanced Options switch for additional edit options.
3. Remove the Acorn by selecting the Remove option from your Acorn dashboard.

## Conclusion
In this tutorial we show how we can use the Acornfile and get our Jellyfin server up and running.





