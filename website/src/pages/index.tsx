import React, {type ReactNode} from 'react';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import CodeBlock from '@theme/CodeBlock';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className="custom-hero">
      <div className="container">
        <Heading as="h1" className="hero-title">
          {siteConfig.title}
        </Heading>
        <p className="hero-subtitle">{siteConfig.tagline}</p>
        <div className="hero-buttons">
          <Link className="btn-primary" to="/docs/intro">
            Get Started 🚀
          </Link>
          <Link className="btn-secondary" href="https://github.com/kenjiz/vm_result">
            GitHub
          </Link>
        </div>
      </div>
    </header>
  );
}

interface FeatureItem {
  title: string;
  icon: string;
  description: string;
}

const features: FeatureItem[] = [
  {
    title: 'Zero-Boilerplate Async Guards',
    icon: '🛡️',
    description: 'Wrap your network or repository fetches in run(). It handles loading, data updates, and try-catch blocks automatically.',
  },
  {
    title: 'Automatic Deduplication',
    icon: '⚡',
    description: 'Avoid API spam. Guards naturally drop concurrent duplicate execution requests, keeping your server traffic clean.',
  },
  {
    title: 'Optimistic UI Updates',
    icon: '🪄',
    description: 'Instantly update the local state for a snappier UI, with built-in automatic rollbacks if the remote operation fails.',
  },
  {
    title: 'Cancel-and-Replace Semantics',
    icon: '🔍',
    description: 'Perfect for search-as-you-type inputs. Stale async actions are safely cancelled when a newer request is triggered.',
  },
  {
    title: 'One-Shot UI Effects',
    icon: '💬',
    description: 'Cleanly dispatch transient notifications like snackbars, toasts, or navigation without polluting persistent widget states.',
  },
  {
    title: 'Custom Logging Bridge',
    icon: '📝',
    description: 'Pluggable logging registration. Route all ViewModel logs directly into Sentry, Crashlytics, or Talker in a single line.',
  },
];

function FeaturesSection() {
  return (
    <section className="features-section">
      <div className="features-container">
        <div className="text--center">
          <Heading as="h2" className="code-info-title">Designed for Developer Velocity</Heading>
          <p style={{fontSize: '1.1rem', opacity: 0.8, maxWidth: '600px', margin: '0 auto 3rem auto'}}>
            Ditch boilerplate and build clean, reactive MVVM features in Flutter.
          </p>
        </div>
        <div className="feature-grid">
          {features.map((feat, idx) => (
            <div key={idx} className="feature-card">
              <div className="feature-icon-wrapper">{feat.icon}</div>
              <Heading as="h3" className="feature-card-title">{feat.title}</Heading>
              <p className="feature-card-desc">{feat.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

const vmCode = `class UserViewModel extends VMResult<User> {
  UserViewModel(this._api) : super(const Result.initial());
  final UserApi _api;

  // Handles loading, data, error state, 
  // try-catch, and api-request deduplication!
  Future<void> fetchUser(String id) {
    return run(() => _api.getUser(id));
  }
}`;

const viewCode = `ResultBuilder<User>(
  listenable: viewModel,
  builder: (context, state, child) {
    return state.when(
      initial: () => const Text('Tap to load'),
      loading: () => const CircularProgressIndicator(),
      data: (user) => Text('Hello \${user.name}!'),
      error: (err) => Text('Failed: \$err'),
    );
  },
)`;

function CodePreviewSection() {
  return (
    <section className="code-preview-section">
      <div className="code-preview-container">
        <div className="code-preview-grid">
          <div className="code-info">
            <Heading as="h2" className="code-info-title">Declarative state, resolved.</Heading>
            <p className="code-info-desc">
              Stop writing custom event loops, stream controllers, or multiple loading-state variables for every screen. 
              Let <code>vm_result</code> handle the lifecycles so you can focus on building features.
            </p>
            <ul className="code-bullets">
              <li className="code-bullet-item">
                <span className="code-bullet-icon">✓</span>
                <span>Type-safe pattern matching.</span>
              </li>
              <li className="code-bullet-item">
                <span className="code-bullet-icon">✓</span>
                <span>Standardized, predictable lifecycle across all features.</span>
              </li>
              <li className="code-bullet-item">
                <span className="code-bullet-icon">✓</span>
                <span>Lightweight, relying on Flutter's native <code>ChangeNotifier</code>.</span>
              </li>
            </ul>
          </div>
          <div>
            <Heading as="h4">1. Declare the ViewModel</Heading>
            <CodeBlock language="dart">{vmCode}</CodeBlock>
            <Heading as="h4" style={{marginTop: '1.5rem'}}>2. Match the State in UI</Heading>
            <CodeBlock language="dart">{viewCode}</CodeBlock>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} - MVVM state management`}
      description="A minimal, production-grade MVVM ViewModel contract for Flutter using ChangeNotifier and ValueListenable.">
      <HomepageHeader />
      <main>
        <FeaturesSection />
        <CodePreviewSection />
      </main>
    </Layout>
  );
}
