# Changelog

## 1.6.0

- Bump [hassio-addons/base-python](https://github.com/hassio-addons/addon-base-python) to 18.0.0

## 1.5.0

- Add manual MQTT configuration to the addon
- Add translations for the configuration screen

## 1.4.1

- Add log output for MQTT and Meter configuration prior to running

## 1.4.0

- Downgrade [hassio-addons/base-python](https://github.com/hassio-addons/addon-base-python) to 13.1.3 to address OpenSSL issue

## 1.3.2

- vendor OpenSSL config to try and get OpenSSL to cooperate with the meter again

## 1.3.1

- Lots of documentation updates
- Fix OpenSSL config to allow unsafe ciphers again

## 1.3.0

- Update [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt) to change `timePeriod_duration` to `duration` device class (via [#12](https://github.com/wingrunr21/hassio-xcel-itron-mqtt/pull/12))
- Add default `BUILD_FROM` argument to `Dockerfile`
- Bump [hassio-addons/base-python](https://github.com/hassio-addons/addon-base-python) to 15.0.1

## 1.2.1

- Fix Dockerfile to maintain upstream directory structure

## 1.2.0

- Update [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt) to address missing `touTier` from [zaknye/xcel_itron2mqtt#25](https://github.com/zaknye/xcel_itron2mqtt/pull/25)
- Bump [hassio-addons/base-python](https://github.com/hassio-addons/addon-base-python) to 13.1.3

## 1.1.0

- Update [zaknye/xcel_itron2mqtt](https://github.com/zaknye/xcel_itron2mqtt) to use retry functionality from [zaknye/xcel_itron2mqtt#24](https://github.com/zaknye/xcel_itron2mqtt/pull/24)
- Bump [hassio-addons/base-python](https://github.com/hassio-addons/addon-base-python) to 13.1.1

## 1.0.1

- Fix `libssl3` and `libcrypto3` standalones conflicting with OpenSSL
- Bump [hassio-addons/base-python](https://github.com/hassio-addons/addon-base-python) to to 13.0.0

## 1.0.0

- Initial release
