def infer_columns(args, source_columns) -> dict:
    for column in args['columns_to_scale']:
        if not ('overwrite_columns' in args and args['overwrite_columns']):
            source_columns[f"{column}_STANDARD_SCALED"] = 'float'
        else:
            source_columns[column.upper()] = 'float'
    return source_columns
