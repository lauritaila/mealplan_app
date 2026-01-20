import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PremiunScreen extends StatelessWidget {
	final String title;
	final String message;

	const PremiunScreen({
		super.key,
		required this.title,
		required this.message,
	});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(title),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => context.go('/home'),
				),
			),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(24),
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								Icons.workspace_premium,
								size: 72,
								color: Theme.of(context).colorScheme.primary,
							),
							const SizedBox(height: 20),
							Text(
								message,
								textAlign: TextAlign.center,
								style: Theme.of(context).textTheme.titleMedium,
							),
							const SizedBox(height: 12),
							Text(
								'Go premium to keep generating meal plans.',
								textAlign: TextAlign.center,
								style: Theme.of(context).textTheme.bodyMedium,
							),
							const SizedBox(height: 24),
							SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: () => context.go('/home'),
									child: const Text('Go to Home'),
								),
							),
						],
					),
				),
			),
		);
	}
}
