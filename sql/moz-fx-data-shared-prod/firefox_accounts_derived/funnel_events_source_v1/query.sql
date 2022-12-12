WITH fxa_events AS (
  SELECT
    `timestamp`,
    user_id,
    country,
    LANGUAGE,
    app_version,
    os_name,
    os_version,
    event_type,
    utm_term,
    utm_source,
    utm_medium,
    utm_campaign,
    utm_content,
    ua_version,
    ua_browser,
    entrypoint,
    flow_id,
    service,
    email_type,
    email_provider,
    oauth_client_id,
    connect_device_flow,
    connect_device_os,
    sync_device_count,
    sync_active_devices_day,
    sync_active_devices_week,
    sync_active_devices_month,
    email_sender,
    email_service,
    email_template,
    email_version,
  FROM
    `moz-fx-data-shared-prod.firefox_accounts.fxa_all_events`
  WHERE
    DATE(`timestamp`) = @submission_date
    AND event_category IN ('content', 'auth', 'oauth')
)
SELECT
  DATE(`timestamp`) AS submission_date,
  user_id AS client_id,
  `moz-fx-data-shared-prod`.udf.safe_sample_id(user_id) AS sample_id,
  SPLIT(event_type, ' - ')[OFFSET(0)] AS category,
  SPLIT(event_type, ' - ')[OFFSET(1)] AS event,
  [
    STRUCT('service' AS key, service AS value),
    STRUCT('email_type' AS key, email_type AS value),
    STRUCT('oauth_client_id' AS key, oauth_client_id AS value),
    STRUCT('connect_device_flow' AS key, connect_device_flow AS value),
    STRUCT('connect_device_os' AS key, connect_device_os AS value),
    STRUCT('sync_device_count' AS key, sync_device_count AS value),
    STRUCT('email_sender' AS key, email_sender AS value),
    STRUCT('email_service' AS key, email_service AS value),
    STRUCT('email_template' AS key, email_template AS value),
    STRUCT('email_version' AS key, email_version AS value)
  ] AS extra,
  CAST([] AS ARRAY<STRUCT<key STRING, value STRING>>) AS experiments,
  *,
FROM
  fxa_events
