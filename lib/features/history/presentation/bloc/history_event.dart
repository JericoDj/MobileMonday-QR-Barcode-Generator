part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final String? userId;
  const LoadHistory({this.userId});
  @override
  List<Object?> get props => [userId];
}

class ClearHistoryRequested extends HistoryEvent {
  final String? userId;
  const ClearHistoryRequested({this.userId});
  @override
  List<Object?> get props => [userId];
}
