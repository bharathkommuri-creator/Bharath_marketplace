import 'package:flutter/material.dart';
import '../../../models/resale_listing.dart';
import '../../../theme/app_theme.dart';

class TriPartyStatusStepper extends StatelessWidget {
  final TransferStep currentStep;

  const TriPartyStatusStepper({Key? key, required this.currentStep}) : super(key: key);

  int get _stepIndex {
    switch (currentStep) {
      case TransferStep.listed:
        return 0;
      case TransferStep.claimed:
        return 1;
      case TransferStep.providerVerified:
        return 2;
      case TransferStep.completed:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'title': '1. Seller Listed', 'subtitle': 'Booking posted'},
      {'title': '2. Buyer Claimed', 'subtitle': 'Funds in escrow'},
      {'title': '3. Host Verified', 'subtitle': 'Name updated'},
      {'title': '4. Completed', 'subtitle': 'Payout released'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.alt_route_rounded, color: AppTheme.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                '3-Party Transfer Progress',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (index) {
              final isDone = index <= _stepIndex;
              final isCurrent = index == _stepIndex;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: index <= _stepIndex ? AppTheme.primaryGreen : AppTheme.borderLight,
                            ),
                          ),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isDone ? AppTheme.primaryGreen : AppTheme.borderLight,
                          child: isDone
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                ),
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: index < _stepIndex ? AppTheme.primaryGreen : AppTheme.borderLight,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index]['title']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
                        color: isDone ? AppTheme.darkForest : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
