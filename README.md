# Home Assistant Addon for Xcel iTron Riva Gen 5 smart meters -> MQTT

[![Open your Home Assistant instance and add the hassio-xcel-itron-mqtt repository to the Addons Store.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fwingrunr21%2Fhassio-xcel-itron-mqtt)

This project provides a bridge between Xcel Energy iTron Riva Gen 5 smart meters and Home Assistant. It uses [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt) for this functionalitiy but wraps it into a Home Assistant addon.

## Enroll in Xcel Energy Launchpad

1. Go to [Meters and Devices](https://my.xcelenergy.com/MyAccount/s/meters-and-devices/manage-meters-and-devices) in your Xcel account to enroll in Launchpad on your account. This allows you to enroll your smart meter in the program. This could take a few days.
2. Once your meter is enrolled, use the above page to "Manage" your enrollment. You should see your meter labeled as "Ready to Go"
3. Use the "Edit" button to add your wifi credentials to the meter. I have found this to be somewhat finicky. You'll want to use your router to verify whether the meter is on your network.
4. Use your router to give your meter a static IP address on your network (using something like a DHCP reservation)

### Optionally
1. Go [here](https://co.my.xcelenergy.com/s/forms/sdk-access) and fill out that form to get access to the SDK. You should get an email/invite from Github to join the org once you are enrollled. This could take a few days. These repos contain example code from Xcel regarding communicating with the meter.

## Prerequisites

You need an MQTT broker set up. You can either:
  - Have the [MQTT integration](https://www.home-assistant.io/integrations/mqtt/) installed and configured in Home Assistant. MQTT information is loaded into this addon via the Home Assistant Supervisor API
  - Use an external broker other than the Mosquitto addon by configuring the [MQTT settings](https://github.com/wingrunr21/hassio-xcel-itron-mqtt/blob/main/xcel-itron-mqtt/DOCS.md#addon-configuration) with that broker's details

## Setup

1. Add this repository to Home Assistant as a source for third-party addons ([click here](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fwingrunr21%2Fhassio-xcel-itron-mqtt) or use the button at the top of the README). See the [Home Assistant documentation](https://www.home-assistant.io/common-tasks/os#installing-third-party-add-ons) if you have questions.
2. Install Xcel Itron MQTT from the [`Add-On Store`](https://my.home-assistant.io/redirect/supervisor_store/) at the bottom right of the `Settings` -> `Add-ons` window.
3. Certificates and LFDI are generated for you automatically on first start. The certs are placed into the [`addon_configs`](https://developers.home-assistant.io/docs/add-ons/configuration/#add-on-advanced-options) directory which is parallel to your Home Assistant configuration directory. You will need to SSH into your HASS instance to see this as the VSCode addon defaults to using your config directory as its project root.

   - The addon will also populate an `lfdi` configuration option by reading the `lfdi` from the cert/key in that directory. This is for your information only. Changing this setting will not change your `lfdi` as that is calculated from the certificates themselves.
4. Take the generated LFDI over to the [Meters and Devices](https://my.xcelenergy.com/MyAccount/s/meters-and-devices/manage-meters-and-devices) and add a new device. Fill out the form with your LFDI and wait for Xcel to send you an email that a new device was successfully added.
5. Restart the addon and you should hopefully see a new device show up under Home Assistant's MQTT integration
6. Head over to the [Energy dashboard config](https://my.home-assistant.io/redirect/config_energy/) and choose the right devices for Home Assistant to use for its electrical tracking. See [DOCS.md](xcel-itron-mqtt/DOCS.md) or the documentation tab in the addon for more details

## Future

- Integrate something to track TOU rates and expose those

## Building Locally

You can use the `scripts/build-local.sh` utility to build to a local Docker image.
