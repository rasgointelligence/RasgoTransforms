def infer_columns(args, source_columns) -> dict:
    for column in args['input_columns']:
        for window in args['window_sizes']:
            source_columns[f"mean_{column}_{window}"] = 'float'
    return source_columns
