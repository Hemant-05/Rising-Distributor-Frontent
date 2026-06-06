import 'package:flutter/material.dart';
import 'package:raising_india/comman/back_button.dart';
import 'package:raising_india/constant/AppColour.dart';
import 'package:raising_india/comman/simple_text_style.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  TextStyle get _h2 => simple_text_style(
    color: AppColour.black,
    fontSize: 20, // large section titles
    fontWeight: FontWeight.w800,
  );

  TextStyle get _h3 => simple_text_style(
    color: AppColour.black,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  TextStyle get _body => TextStyle(
    fontFamily: 'Sen',
    color: AppColour.black,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColour.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            back_button(),
            const SizedBox(width: 8),
            Text('Term & Conditions', style: simple_text_style(fontSize: 18)),
            const Spacer(),
          ],
        ),
        backgroundColor: AppColour.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro
              Text('Welcome to Rising Mart', style: _h2),
              const SizedBox(height: 8),
              Text(
                'Rising Mart provides on‑demand delivery of groceries and essentials. '
                'By using our app and services, the user agrees to these Terms & Conditions and the Privacy Policy below. '
                'Please read everything carefully.',
                style: _body,
              ),
              const SizedBox(height: 20),

              // TERMS
              Text('Terms & Conditions', style: _h2),
              const SizedBox(height: 8),

              Text('1) Account & Eligibility', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'Users must be 18+ and ensure all profile details (name, phone, address) are accurate.',
              ),
              _bullet(
                'Keep login credentials confidential; actions taken through the account are the user’s responsibility.',
              ),

              const SizedBox(height: 12),
              Text('2) Orders & Acceptance', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'Placing an order is an offer to purchase; confirmation depends on stock and serviceability.',
              ),
              _bullet(
                'We may limit quantities or cancel in cases of unserviceable address, pricing error, or suspected fraud.',
              ),
              _bullet(
                'Perishable items may have limited return eligibility (see Refunds & Returns).',
              ),

              const SizedBox(height: 12),
              Text('3) Pricing, Payments & Promotions', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'Prices include applicable taxes unless stated otherwise and are shown before payment.',
              ),
              _bullet(
                'Promotions, coupons, and cashbacks are subject to specific terms and validity windows.',
              ),
              _bullet(
                'Refunds for cancellations/returns are processed to the original method or wallet as per policy.',
              ),

              const SizedBox(height: 12),
              Text('4) Substitutions', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'If an item is unavailable, a similar product may be offered based on saved preferences or consent.',
              ),
              _bullet(
                'Substitutions can be declined at delivery; the bill will be adjusted accordingly.',
              ),

              const SizedBox(height: 12),
              Text('5) User Conduct', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'Do not attempt spam, abuse, scraping, reverse engineering, or policy violations.',
              ),
              _bullet(
                'Respect delivery partners and community guidelines for safe and timely fulfillment.',
              ),

              const SizedBox(height: 12),
              Text('6) Service Changes & Termination', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'We may update app features, fees, and policies with in‑app or email notice.',
              ),
              _bullet(
                'Accounts may be suspended/terminated for fraud, abuse, or repeated violations.',
              ),

              const SizedBox(height: 12),
              Text('7) Governing Law & Disputes', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'These terms are governed by applicable laws of India, with exclusive jurisdiction of competent courts.',
              ),

              const SizedBox(height: 20),

              // PRIVACY
              Text('Privacy Policy', style: _h2),
              const SizedBox(height: 8),

              Text('1) Data We Collect', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'Profile data (name, phone, email), addresses, and order history to fulfill orders.',
              ),
              _bullet(
                'Device and usage data (app events, diagnostics) to improve performance and prevent fraud.',
              ),
              _bullet(
                'Approximate or precise location (with permission) for address detection and accurate ETAs.',
              ),

              const SizedBox(height: 12),
              Text('2) How We Use Data', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'To process orders, payments, refunds, and customer support.',
              ),
              _bullet(
                'To personalize catalog, recommendations, and promotions, including notifications.',
              ),
              _bullet(
                'To ensure safety, security, and compliance with legal obligations.',
              ),

              const SizedBox(height: 12),
              Text('3) Sharing & Disclosure', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'With delivery partners, payment gateways, logistics, and support tools strictly for fulfillment.',
              ),
              _bullet(
                'With authorities when required by law. Rising Mart does not sell personal data.',
              ),

              const SizedBox(height: 12),
              Text('4) Security & Retention', style: _h3),
              const SizedBox(height: 6),
              _bullet(
                'Industry‑standard safeguards including encryption, access controls, and periodic audits.',
              ),
              _bullet(
                'Data is retained to meet legal/accounting needs and is then deleted or anonymized.',
              ),

              const SizedBox(height: 12),
              Text('5) Your Choices & Rights', style: _h3),
              const SizedBox(height: 6),
              _bullet('Update profile and addresses in the app at any time.'),
              _bullet(
                'Opt‑out of promotional communications in settings; transactional messages continue.',
              ),
              _bullet(
                'Request data deletion subject to legal retention requirements.',
              ),

              const SizedBox(height: 20),

              // REFUNDS & RETURNS
              Text('Refunds & Returns', style: _h2),
              const SizedBox(height: 8),
              _bullet(
                'Report issues within 24 hours of delivery via Order Help with photos if applicable.',
              ),
              _bullet(
                'Eligible: missing items, wrong items, damaged/spoiled perishables at delivery.',
              ),
              _bullet(
                'Ineligible: items opened/used after delivery unless defective; items outside the window.',
              ),
              _bullet(
                'Refund timeline: typically 3–5 business days to original method or wallet after approval.',
              ),
              _bullet(
                'Cancellations: free before packing; charges may apply after dispatch. Prepaid orders are refunded upon successful cancellation.',
              ),

              const SizedBox(height: 20),

              // DELIVERY & FEES
              Text('Delivery & Fees', style: _h2),
              const SizedBox(height: 8),
              _bullet(
                'ETAs and slots shown at checkout are estimates; delays may occur due to weather or traffic.',
              ),
              _bullet(
                'Fees vary by basket size, distance, and surge; all charges are shown before payment.',
              ),
              _bullet(
                'Contactless drop is available on request; ensure an active phone number during delivery.',
              ),
              _bullet(
                'Age‑restricted items may require valid ID verification.',
              ),
              _bullet(
                'Failed delivery due to unreachable customer or inaccessible address may incur fees.',
              ),

              const SizedBox(height: 20),

              // CONTACT
              Text('Contact & Support', style: _h2),
              const SizedBox(height: 8),
              _bullet('Email: support@risingmart.in'),
              _bullet('Hours: 9:00 AM – 9:00 PM IST, 7 days a week.'),
              const SizedBox(height: 12),

              // Footer note
              Text(
                'Updates: We may revise these policies; significant changes will be notified in‑app or via email. '
                'Continued use after updates constitutes acceptance of the revised policies.',
                style: _body,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('- ', style: _body),
          Expanded(child: Text(text, style: _body)),
        ],
      ),
    );
  }
}
