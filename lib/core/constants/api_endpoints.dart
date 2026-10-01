/// All API endpoint paths — matches backend controllers exactly
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ─────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String brokerRegister = '/auth/broker/register';
  static const String agentRegister = '/auth/agent/register';

  // ── Portal – Dashboard ────────────────────────────────────
  static const String customerStats = '/portal/dashboard/customer-stats';
  static const String agentStats = '/portal/dashboard/agent-stats';

  // ── Portal – Policies ─────────────────────────────────────
  static const String portalPolicies = '/portal/policies';
  static const String portalPolicySearch = '/portal/policies/search';
  static const String portalPolicyTypes = '/portal/policies/types';
  static const String portalVehiclePolicies = '/portal/policies/vehicle';
  static String portalPolicyById(int id) => '/portal/policies/$id';

  // ── Portal – Renewals ─────────────────────────────────────
  static const String portalRenewals = '/portal/renewals';

  // ── Portal – Insurances (my policies) ────────────────────
  static const String portalInsurances = '/portal/insurances';
  static String portalInsuranceById(int id) => '/portal/insurances/$id';

  // ── Insurance sub-entities ────────────────────────────────
  static String insuredPersons(int insuranceId) => '/insurances/$insuranceId/insured';
  static String insuredPersonById(int insuranceId, int id) => '/insurances/$insuranceId/insured/$id';
  static String nominees(int insuranceId) => '/insurances/$insuranceId/nominees';
  static String nomineeById(int insuranceId, int id) => '/insurances/$insuranceId/nominees/$id';
  static String insurancePayments(int insuranceId) => '/insurances/$insuranceId/payments';
  static String insurancePaymentById(int insuranceId, int id) => '/insurances/$insuranceId/payments/$id';
  static String insurancePaymentStatus(int insuranceId, int id) => '/insurances/$insuranceId/payments/$id/status';
  static String insurancePaymentReceipt(int insuranceId, int id) => '/insurances/$insuranceId/payments/$id/receipt';
  static String insuranceDocuments(int insuranceId) => '/insurances/$insuranceId/documents';
  static String insuranceDocumentById(int insuranceId, int id) => '/insurances/$insuranceId/documents/$id';
  static String insuranceDocumentStatus(int insuranceId, int id) => '/insurances/$insuranceId/documents/$id/status';

  // ── Portal – Claims ───────────────────────────────────────
  static const String portalClaims = '/portal/claims';
  static String portalClaimById(int id) => '/portal/claims/$id';

  // ── Claim documents ───────────────────────────────────────
  static String claimDocuments(int claimId) => '/claims/$claimId/documents';
  static String claimDocumentById(int claimId, int id) => '/claims/$claimId/documents/$id';
  static String claimDocumentStatus(int claimId, int id) => '/claims/$claimId/documents/$id/status';

  // ── Portal – Notices ──────────────────────────────────────
  static const String portalNotices = '/portal/notices';

  // ── Portal – Settings ─────────────────────────────────────
  static const String portalSettings = '/portal/settings/public';

  // ── Portal – Subscriptions ────────────────────────────────
  static const String portalSubscriptions = '/portal/subscriptions';

  // ── Portal – Transactions ─────────────────────────────────
  static const String portalTransactions = '/portal/transactions';
  static String portalTransactionReceipt(int id) => '/portal/transactions/$id/receipt';

  // ── Portal – Histories ────────────────────────────────────
  static const String portalHistories = '/portal/histories';

  // ── Portal – Customer ─────────────────────────────────────
  static const String portalCustomerProfile = '/portal/customer/profile';
  static const String portalCustomerAgents = '/portal/customer/agents';

  // ── Portal – Lookups ──────────────────────────────────────
  static const String portalPolicySubTypes = '/portal/policy-sub-types';
  static const String portalPolicyDurations = '/portal/policy-durations';
  static const String portalPolicyFors = '/portal/policy-fors';
  static const String portalDocumentTypes = '/portal/document-types';

  // ── Portal – Agent ──────────────────────────────────────
  static const String agentCustomers = '/portal/agent/customers';
  static String agentCustomerById(int id) => '/portal/agent/customers/$id';
  static String agentCustomerDetail(int id) => '/portal/agent/customers/$id/detail';
  static const String agentDocumentTypes = '/portal/document-types';
  static const String agentPolicyDurations = '/portal/policy-durations';
  static const String agentPolicyFors = '/portal/policy-fors';
  static const String agentPolicySubTypes = '/portal/policy-sub-types';
  static const String agentQuotes = '/portal/quotes';
  static String agentQuoteById(int id) => '/portal/quotes/$id';
  static const String agentEndorsements = '/portal/endorsements';
  static String agentEndorsementById(int id) => '/portal/endorsements/$id';
  static String agentEndorsementsForInsurance(int insuranceId) => '/portal/endorsements/insurance/$insuranceId';

  // ── Portal – Broker ──────────────────────────────────────
  static const String brokerDashboard = '/portal/broker/dashboard';
  static const String brokerAgreements = '/portal/broker/agreements';
  static String brokerAgreementById(int id) => '/portal/broker/agreements/$id';
  static const String brokerPolicies = '/portal/broker/policies';
  static const String brokerClaims = '/portal/broker/claims';
  static const String brokerClients = '/portal/broker/clients';
  static const String brokerDocuments = '/portal/broker/documents';
  static const String brokerEndorsements = '/portal/broker/endorsements';
  static const String brokerKycUpload = '/portal/broker/kyc-upload';
  static const String brokerNotificationPrefs =
      '/portal/broker/notification-preferences';
  static const String brokerProfile = '/portal/broker/profile';

  // ── Contact (public) ─────────────────────────────────────
  static const String contact = '/contact';

  // ── Taxes (public) ───────────────────────────────────────
  static const String activeTaxes = '/admin/taxes/active';
}
