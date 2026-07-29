import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class HowItWorksBanner extends StatelessWidget {
  const HowItWorksBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightMintBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.diversity_3_rounded, color: AppTheme.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'How 3-Party Booking Resale Works',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStep('1', 'Seller Lists', 'Original buyer uploads cancelled slot'),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
              _buildStep('2', 'Host Verifies', 'Hotel/Venue approves transfer'),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textMuted),
              _buildStep('3', 'Buyer Claims', 'New guest saves up to 50%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String title, String sub) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.primaryGreen,
            child: Text(
              num,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
