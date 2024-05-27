#!/bin/bash

admin_sdk_url="https://firebasestorage.googleapis.com/v0/b/ios-entertainment-photography.appspot.com/o/adminSdk.json?alt=media&token=e5e3eff8-215f-4a85-b10b-64554a837e1f"
admin_sdk_path="adminSdk.json"

curl -o "$admin_sdk_path" "$admin_sdk_url"
