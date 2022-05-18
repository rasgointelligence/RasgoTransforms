def infer_columns(args, source_columns) -> dict:
    if 'drop' in args and args['drop']:
        source_columns['OUTLIER'] = 'boolean'
    return source_columns
