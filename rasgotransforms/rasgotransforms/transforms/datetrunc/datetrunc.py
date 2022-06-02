def infer_columns(args, source_columns) -> dict:
    for target_col, date_part in args['dates'].items():
        source_columns[f"{target_col}_{date_part}".upper()] = source_columns[target_col.upper()]
    return source_columns
