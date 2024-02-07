# Home Assistant Addon for Xcel iTron Riva Gen 5 smart meters -> MQTT

This project provides a bridge between Xcel Energy iTron Riva Gen 5 smart meters and Home Assistant. It uses [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt) for this functionalitiy but wraps it into a Home Assistant addon.

## Enroll in Xcel Energy Launchpad

1. Go [here](https://co.my.xcelenergy.com/s/forms/sdk-access) and fill out that form to get access to the SDK. You should get an email/invite from Github to join the org once you are enrollled. This could take a few days.
2. Go to [Meters and Devices](https://my.xcelenergy.com/MyAccount/s/meters-and-devices/manage-meters-and-devices) in your Xcel account to enroll in Launchpad on your account. This allows you to enroll your smart meter in the program. This could take a few days.
3. Once your meter is enrolled, use the above page to "Manage" your enrollment. You should see your meter labeled as "Ready to Go"
4. Use the "Edit" button to add your wifi credentials to the meter. I have found this to be somewhat finicky. You'll want to use your router to verify whether the meter is on your network.

## Setup

1. Add this repository to Home Assistant as a source for third-party addons. See the [Home Assistant documentation](https://www.home-assistant.io/common-tasks/os#installing-third-party-add-ons) if you have questions on how to do that.
2. Install the Xcel Itron MQTT addon.
3. Certificates and LDFI are generated for you automatically on first start. The certs are placed into the [`addon_configs`](https://developers.home-assistant.io/docs/add-ons/configuration/#add-on-advanced-options) directory which is parallel to your Home Assistant configuration directory. You will need to SSH into our HASS instance to see this as the VSCode addon defaults to using your config directory as its project root. <br /><br />The addon will also populate an `ldfi` configuration option by reading the `ldfi` from the cert/key in that directory. This is for your information only. Changing this setting will not change your `ldfi` as that is calculated from the certificates themselves.
4. Take the generated LDFI over to the [Meters and Devices](https://my.xcelenergy.com/MyAccount/s/meters-and-devices/manage-meters-and-devices) and add a new device. Fill out the form with your LDFI and wait for Xcel to send you an email that a new device was successfully added.
5. Restart the addon and you should hopefully see a new device show up under Home Assistant's MQTT integration
6. Head over to the Energy dashboard and choose the right devices for Home Assistant to use for its electrical tracking.

## Future

- Using built-in MQTT discovery right now. Need to add config options to allow an external MQTT broker to be used (if that broker is configured in HASS will it be auto-exposed too?)
- Integrate something to track TOU rates and expose those

## Building Locally

Check the current version of `hassio-addons/addon-base-python` currently being used in [`build.yaml`](https://github.com/wingrunr21/hassio-xcel-itron-mqtt/blob/main/xcel-itron-mqtt/build.yaml). You can then `cd` to the `xcel-itron-mqtt` directory and run the following to build the container locally: `docker build --build-arg BUILD_FROM="ghcr.io/hassio-addons/base-python:<base-python-version-here>" -t local/hassio-xcel-itron-mqtt .`
