{% set ds = var('ds', default = '{{ ds }}') %}
{% set ds_nodash = var('ds_nodash', default = '{{ ds_nodash }}') %}
{% set hour = var('hour', default = "{{ macros.datetime.strptime(ts, '%Y-%m-%dT%H:%M:%S+00:00').strftime('%H') }}") %}
{% set next_ds_nodash = var('next_ds_nodash', default = '{{ next_ds_nodash }}') %}
{% set prev_ds = var('prev_ds', default = '{{ prev_ds }}') %}
{% set processing_hour = var('processing_hour', default = "{{ macros.datetime.strptime(ts, '%Y-%m-%dT%H:%M:%S+00:00').strftime('%Y-%m-%d %H:00:00') }}") %}
{% set ts = var('ts', default = '{{ ts }}') %}

{{
    config(
    enabled = true,
    tags = ["dwd","integration","daily"],
    meta = {
        'product_code': 'de',
        'owner': 'zh.dai@aftership.com',
        'start_date': '2023-08-08',
        'schedule_interval': '22 2 */1 * *',
        'catchup': false,
        'ge': {
            'enabled': true,
            'sample_pre_days': 1,'comment': '与n天前对比',
            'rules': {
                'expect_table_row_count_has_increased': {'comment': 's表规则:数据每日增长或不变',
                    'enable': true,
                    'upper_percent': 150,
                    'lower_percent': 100
                },
                'expect_table_row_count_in_range': {'comment': 'i表规则:数据每日在合理范围内波动',
                    'enable': true,
                    'upper_percent': 200,
                    'lower_percent': 30
                },
                'expect_table_row_count_not_zero': {
                    'enable': true
                },
                'expect_column_primary_key_unique': {
                    'enable': false,
                    'primary_key': ['col1', 'col2']
                },
            }
        }
    },
    schema = 'dwd_utc_00',
    materialized = 'incremental',
    incremental_strategy = 'insert_overwrite',
    partition_by = {
        'field': 'processing_time',
        'data_type': 'timestamp',
        'granularity': 'day'
    },
    partitions=["'" + ds + "'"],
    require_partition_filter =  true     
)
}}

SELECT
    *,
    '123' as aa,
    '456' as bb,
    '333' as cc
FROM dwd_utc_00.dwd_integration_de_api_data_enrichment_contact_s_d
WHERE processing_time = '{{ ds }}'

