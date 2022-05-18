def infer_columns(args, source_columns) -> dict:
    if not ('overwrite_columns' in args and args['overwrite_columns']):
        for column in args['columns_to_scale']:
            source_columns[f"{column}_MIN_MAX_SCALED"] = source_columns[column]
    return source_columns
