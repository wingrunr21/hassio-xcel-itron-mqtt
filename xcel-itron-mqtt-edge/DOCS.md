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

## Troubleshooting

### Summation Delivered Value Stops

This usually means your meter needs restarted. Email Xcel at EnergyLaunchpad@xcelenergy.com and ask that they reboot your meter.
