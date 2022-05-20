def infer_columns(args, source_columns) -> dict:
    for target_col, date_part in args['dates'].items():
        source_columns[f"{target_col}_{date_part}".upper()] = 'int'
    return source_columns
