DATE_PARTS = [
    'year',
    'month',
    'day',
    'dayofweek',
    'dayofweekiso',
    'dayofyear',
    'week',
    'weekiso',
    'quarter',
    'yearofweek',
    'yearofweekiso',
]
TIME_PARTS = [
    'hour',
    'minute',
    'second',
    'millisecond',
    'nanosecond',
    'epoch_second',
    'epoch_millisecond',
    'epoch_microsecond',
    'epoch_nanosecond',
    'timezone_hour',
    'timezone_minute',
]


def infer_columns(args, source_columns) -> dict:
    if args['date'] in source_columns:
        output_type = source_columns[args['date']]
    else:
        output_type = 'date'
    if 'overwrite_columns' in args and args['overwrite_columns']:
        source_columns[args['date'].upper()] = output_type
    elif 'alias' in args and args['alias']:
        source_columns[args['alias']] = output_type
    else:
        source_columns[f"{args['date']}_add{args['offset']}{args['date_part']}".upper()] = output_type
    return source_columns
