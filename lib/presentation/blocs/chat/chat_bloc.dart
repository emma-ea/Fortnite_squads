import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/repositories/chat_repository.dart';

// --- Events ---
abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String squadId;
  LoadMessages(this.squadId);
}

class SendMessagePressed extends ChatEvent {
  final String squadId;
  final String text;
  SendMessagePressed({required this.squadId, required this.text});
}

class SendImagePressed extends ChatEvent {
  final String squadId;
  final File image;
  SendImagePressed({required this.squadId, required this.image});
}

class NewMessageReceived extends ChatEvent {
  final Message message;
  NewMessageReceived(this.message);
}

// --- States ---
abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}
class ChatLoading extends ChatState {}
class ChatLoaded extends ChatState {
  final List<Message> messages; // Ordered newest first for ListView(reverse: true)
  
  ChatLoaded(this.messages);
  
  @override
  List<Object?> get props => [messages];
}
class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

// --- BLoC ---
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _messageSubscription;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessagePressed>(_onSendMessage);
    on<SendImagePressed>(_onSendImage);
    on<NewMessageReceived>(_onNewMessageReceived);

    // Listen to the repository stream for real-time updates
    _messageSubscription = _chatRepository.messageStream.listen((message) {
      add(NewMessageReceived(message));
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await _chatRepository.getMessages(event.squadId);
    
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(ChatLoaded(messages)),
    );
  }

  Future<void> _onSendMessage(SendMessagePressed event, Emitter<ChatState> emit) async {
    // Optimistic update logic could go here
    final result = await _chatRepository.sendMessage(event.squadId, event.text);
    
    if (result.isLeft()) {
       // Handle error (e.g., show toast), state remains loaded
    }
  }

  Future<void> _onSendImage(SendImagePressed event, Emitter<ChatState> emit) async {
    await _chatRepository.sendImageMessage(event.squadId, event.image);
  }

  void _onNewMessageReceived(NewMessageReceived event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      final currentMessages = List<Message>.from((state as ChatLoaded).messages);
      // Add new message to the top (because list is reversed)
      currentMessages.insert(0, event.message); 
      emit(ChatLoaded(currentMessages));
    }
  }
}