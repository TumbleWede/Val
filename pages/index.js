import Link from "@docusaurus/Link"
import useDocusaurusContext from "@docusaurus/useDocusaurusContext"
import Layout from "@theme/Layout"
import clsx from "clsx"
import React from "react"
import styles from "./index.module.css"

function Header() {
	const { siteConfig } = useDocusaurusContext()
	return (
		<header className={clsx("hero ", styles.heroBanner)}>
			<div className="container">
				<h1 className="hero__title">
					<img src={"logo.png"} alt="Val" />
				</h1>
				<p className="hero__subtitle">{siteConfig.tagline}</p>
				<div className={styles.buttons}>
					<Link
						className={`button button--secondary button--lg ${styles.button}`}
						to="/docs/intro"
					>
						Get Started
					</Link>

					<Link
						className="button button--primary button--lg"
						to="/api/Val"
					>
						View API
					</Link>
				</div>
			</div>
		</header>
	)
}

const FeatureList = [
	{
		title: "Zero Dependencies",
		description: (
			<>
				The source code for the Val library is a single file.
			</>
		),
	},
	{
		title: "Universal Reactivity",
		description: (
			<>
				Val contains only one class to represent states, computeds, and scopes. This means that all of Val's features can be applied to all Val objects.
			</>
		),
	},
	{
		title: "Simple API",
		description: (
			<>
				Val is a beginner-friendly approach to state management designed to be as simple as possible while remaining a powerful library.
			</>
		),
	},
]

function Feature({ title, description }) {
	return (
		<div className={clsx("col col--4")}>
			<div className="text--center padding-horiz--md">
				<h3>{title}</h3>
				<p>{description}</p>
			</div>
		</div>
	)
}

export default function Home() {
	const { siteConfig } = useDocusaurusContext()
	return (
		<Layout
			title={`${siteConfig.title}`}
			description="A simple, lightweight state container library."
		>
			<Header />
			<section className={styles.features}>
				<div className="container">
					<div className="row">
					{FeatureList.map((props, idx) => (
						<Feature key={idx} {...props} />
					))}
					</div>
				</div>
			</section>
		</Layout>
	)
}