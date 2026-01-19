import 'package:equatable/equatable.dart';
import '../data/intake_model.dart'; // Import IntakeModel

abstract class HydrationState extends Equatable {
  const HydrationState();

  @override
  List<Object> get props => [];
}

class HydrationInitial extends HydrationState {}

class HydrationLoading extends HydrationState {}

class HydrationLoaded extends HydrationState {
  final int currentIntake;
  final List<IntakeModel> history; // --- NEW: History List ---
  final bool hasUnsyncedData;

  const HydrationLoaded(
    this.currentIntake, 
    this.history, 
    {this.hasUnsyncedData = false}
  );

  @override
  List<Object> get props => [currentIntake, history, hasUnsyncedData];
}

class HydrationError extends HydrationState {
  final String message;

  const HydrationError(this.message);

  @override
  List<Object> get props => [message];
}