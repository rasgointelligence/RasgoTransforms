def infer_columns(args, source_columns) -> dict:
    source_columns[f"{args['date_col']}_spine_start"] = 'timestamp_ntz'
    source_columns[f"{args['date_col']}_spine_end"] = 'timestamp_ntz'
    return source_columns
