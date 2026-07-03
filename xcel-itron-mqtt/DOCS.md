## Addon Configuration

### Setting the MQTT configuration will override the Mosquitto broker's automatic service discovery

| Option              | Description                                                                 | Required | Default Value    |
| ------------------- | --------------------------------------------------------------------------- | -------- | ---------------- |
| `meter_ip`          | The IP address of your meter                                                | Yes      |                  |
| `meter_port`        | The port of your meter                                                      | Yes      | 8081             |
| `cert_dir`          | The directory to store the certificate and key                              | Yes      | `/config/certs`  |
| `cert_file`         | The name of the certificate file                                            | Yes      | `cert.pem`       |
| `key_file`          | The name of the key file                                                    | Yes      | `key.pem`        |
| `mqtt`              | MQTT server configuration. Takes precedence over the Mosquitto broker addon | No       |
| `mqtt.server`       | MQTT server address                                                         | No       |
| `mqtt.port`         | Port of the MQTT server                                                     | No       | 1883             |
| `mqtt.user`         | Username for the MQTT server                                                | No       |                  |
| `mqtt.password`     | Password for the MQTT server                                                | No       |                  |
| `mqtt.topic_prefix` | The prefix for the MQTT topics                                              | No       | `homeassistant/` |

## Configuring Energy Dashboard

[![Open your Home Assistant instance and show your energy configuration panel.](https://my.home-assistant.io/badges/config_energy.svg)](https://my.home-assistant.io/redirect/config_energy/)

![Eletricity Grid Config](https://raw.githubusercontent.com/wingrunr21/hassio-xcel-itron-mqtt/refs/heads/main/images/electricity_grid.png)

1. Open up the [Energy config](https://my.home-assistant.io/redirect/config_energy/) for Home Assistant
2. Set up the `Grid consumption` sensor to use the value from your meter (usually named `sensor.xcel_itron_5_current_summation_delivered_value`)
3. If you have solar or a way to return energy to the grid, also set the return sensor (usually named `sensor.xcel_itron_5_current_summation_received_value`)
4. Optionally, set up the [Electricity Maps (formerly CO2Signal) integration](https://www.home-assistant.io/integrations/co2signal/)
5. Give Home Assistant some time to collect data and then you should start seeing things populate in your [Energy Dashboard!](https://my.home-assistant.io/redirect/energy/)

## Meter status sensor

A `problem` binary sensor that watches how long it's been since the meter last reported is the simplest way to surface connectivity issues for the meter. Add an optional `device_tracker` or `binary_sensor` for network presence to drive availability.

Home Assistant does not currently support Template Sensor Blueprints via the UI ([home-assistant/architecture#1027](https://github.com/home-assistant/architecture/discussions/1027#discussioncomment-10830295)) or linking a device ID via YAML ([home-assistant/core#153286]( https://github.com/home-assistant/core/issues/153286)), so the best method is to manually configure via the UI.

### Template Binary Sensor

Create a [template binary sensor](https://www.home-assistant.io/integrations/template#binary-sensor) helper under **Settings → Devices & Services → Helpers → Create Helper → Template → Template a binary sensor**:

![Template binary sensor helper](https://raw.githubusercontent.com/wingrunr21/hassio-xcel-itron-mqtt/refs/heads/main/images/status_template_binary_sensor.png)

- **Name** – As we are linking this sensor to the specific meter, something simple like "Status" works. If you choose not to link to the device, a more descriptive name is recommended.
- **State** – on (a problem) once the meter hasn't reported within the timeout. Point it at any meter entity that updates every poll (instantaneous demand works well) and adjust the timeout in seconds:

  ```
  {{ (now() - states.sensor.xcel_grid_export_instantaneous_demand_value.last_reported).total_seconds() > 60 }}
  ```

- **Device class** – `Problem`.
- **Device** – select the meter so the sensor is grouped with its other entities.
- **Availability template** (under Advanced options, optional) – mark the sensor unavailable when the meter isn't on the network, e.g. from a router-provided tracker:

  ```
  {{ is_state('device_tracker.itron_smart_meter', 'home') }}
  ```
  Note: the name of this entity will depend on how you have setup tracking the meter's WiFi connection

## Troubleshooting

### Summation Delivered Value Stops

This usually means your meter needs restarted. Email Xcel at EnergyLaunchpad@xcelenergy.com and ask that they reboot your meter.
