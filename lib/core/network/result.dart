class Result<T> {
  Result._();

  factory Result.loading(T msg) = LoadingStateResult<T>;

  factory Result.success(T value) = SuccessStateResult<T>;

  factory Result.error(T msg, {bool sessionExpired, bool resourceNotFound}) =
      ErrorStateResult<T>;
}

class LoadingStateResult<T> extends Result<T> {
  LoadingStateResult(this.msg) : super._();
  final T msg;
}

class ErrorStateResult<T> extends Result<T> {
  ErrorStateResult(
    this.msg, {
    this.sessionExpired = false,
    this.resourceNotFound = false,
  }) : super._();
  final T msg;
  final bool sessionExpired;
  final bool resourceNotFound;
}

class SuccessStateResult<T> extends Result<T> {
  SuccessStateResult(this.value) : super._();
  final T value;
}

extension ResultExtension<T> on Result<T> {
  bool get isLoading => this is LoadingStateResult;

  bool get isSuccess => this is SuccessStateResult;

  bool get isError => this is ErrorStateResult;

  bool get sessionExpired => this is ErrorStateResult
      ? (this as ErrorStateResult<T>).sessionExpired
      : false;

  bool get resourceNotFound => this is ErrorStateResult
      ? (this as ErrorStateResult<T>).resourceNotFound
      : false;

  T? get message {
    if (this is LoadingStateResult<T>) {
      return (this as LoadingStateResult<T>).msg;
    }
    if (this is SuccessStateResult<T>) {
      return (this as SuccessStateResult<T>).value;
    }
    if (this is ErrorStateResult<T>) {
      return (this as ErrorStateResult<T>).msg;
    }
    return null;
  }
}
