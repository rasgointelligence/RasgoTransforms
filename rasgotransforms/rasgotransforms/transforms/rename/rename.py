def infer_columns(args, source_columns) -> dict:
    out_columns = {}
    for column, column_type in source_columns.items():
        if column in args['renames']:
            out_columns[args['renames'][column]] = column_type
        else:
            out_columns[column] = column_type
    return out_columns
