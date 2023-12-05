# Jellyfin Server on Acorn
===

Jellyfin is the volunteer-built media solution that puts you in control of your media. Stream to any device from your own server, with no strings attached. Your media, your server, your way.
 
## Using s3 as your storage.
If you have all your media on s3 and you just want to copy those file to the local jellyfin directory you will need to pass three field 
- access_key
- secret_key
- bucket_name

It will copy all your s3 media to the jellyfin volume.Once your jellyfin server it up and running and if you add more media content after that it will sync it in every 30 minutes. Accordingly you can modify the storge for the media by default it is 2GB you can use the `storage` field to give the storge. If you want to give storage as 10GB you can give `10G` to the storage field.
While selecting the folder select `jellyfinmedia` directory as we are mounting the volume to that directory.

## Mount local directory.

To mount the local dir you need to use acorn cli . Once you connect your acorn cli to the acorn platform. You can mount your local dir something like below 
```
dirs: {
    "/pictures": "./pictures"
    "/pictures2": "volume://jellyfinmedia?subpath=pictures"
}
```
After making above changes to Acornfile run this command `acorn run -n jellyfin .`

_Note: Once you have your jellyfin server running on acorn. When you click on the given click on the UI sometimes it ask's you to add server you can click on it and delete it and refresh the page. You will get the page where it will ask you to create a new account._