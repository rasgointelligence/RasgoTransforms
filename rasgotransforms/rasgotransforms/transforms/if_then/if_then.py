def infer_columns(args, source_columns) -> dict:
    if args['default'].upper() in source_columns:
        output_type = source_columns[args['default']]
    elif args['conditions'][1].upper() in source_columns:
        output_type = source_columns[args['conditions'][1].upper()]
    elif type(args['default']) is int:
        output_type = 'integer'
    elif type(args['default']) is float:
        output_type = 'float'
    else:
        output_type = 'text'
    source_columns[args['alias'].upper()] = output_type
    return source_columns
