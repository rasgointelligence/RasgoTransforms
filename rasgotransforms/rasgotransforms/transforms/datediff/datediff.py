def infer_columns(args, source_columns) -> dict:
    if 'alias' in args:
        source_columns[args['alias']] = 'int'
    else:
        source_columns[f"DIFF_{args['date_1']}_{args['date_2']}"] = 'int'
    return source_columns
