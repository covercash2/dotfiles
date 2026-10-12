// Bridges Dataview's query engine into the Local REST API plugin's MCP
// server, via that plugin's documented extension interface
// (getAPI -> addMcpTool). See README discussion in dotfiles repo history
// for why this exists: the official REST API/MCP plugin has no native
// Dataview integration, and DataviewJS only runs inside Obsidian's own
// plugin runtime, so there is no way to expose it over HTTP without this.
import { Plugin } from "obsidian";
import { z } from "zod";

// Obsidian's plugin registry (`app.plugins.plugins[id]`) isn't part of the
// public `obsidian` package types — these are the minimal shapes we touch.
interface DataviewQueryResult {
	successful: boolean;
	value?: unknown;
	error?: string;
}

interface DataviewApi {
	query(source: string, originFile?: string): Promise<DataviewQueryResult>;
	queryMarkdown(source: string, originFile?: string): Promise<{ successful: boolean; value?: string; error?: string }>;
	pages(query?: string): unknown;
	[key: string]: unknown;
}

interface LocalRestApiPublicApi {
	addMcpTool(
		name: string,
		description: string,
		schema: Record<string, z.ZodTypeAny>,
		callback: (args: Record<string, unknown>) => Promise<unknown>,
	): void;
}

// Render-style helpers a real dataviewjs block gets (dv.header, dv.table,
// ...) that normally mutate Obsidian's editor DOM. There is no DOM here, so
// each one just appends a record of what it was asked to render — the
// result comes back as `rendered` alongside whatever the script `return`s.
function buildJsShim(dv: DataviewApi): { shim: DataviewApi; rendered: unknown[] } {
	const rendered: unknown[] = [];
	const shim = Object.create(dv) as DataviewApi;
	shim.header = (level: number, text: unknown) => rendered.push({ type: "header", level, text: String(text) });
	shim.paragraph = (text: unknown) => rendered.push({ type: "paragraph", text: String(text) });
	shim.span = shim.paragraph;
	shim.el = (tag: string, text: unknown) => rendered.push({ type: "el", tag, text: String(text) });
	shim.list = (items: unknown) => rendered.push({ type: "list", items });
	shim.table = (headers: unknown, rows: unknown) => rendered.push({ type: "table", headers, rows });
	return { shim, rendered };
}

export default class ObsidianDataviewMcpExtension extends Plugin {
	private restApi: LocalRestApiPublicApi | undefined;

	async onload() {
		this.registerWithLocalRestApi();
		// `app.workspace` fires this event (not in obsidian's typings) every
		// time the Local REST API plugin finishes loading — including after
		// it reloads during development or an update, at which point our
		// previous registration is on a dead instance. Don't guard this with
		// `if (this.restApi) return` — that keeps the stale handle.
		this.registerEvent(
			(this.app.workspace as unknown as { on: (name: string, cb: () => void) => { fn: unknown } }).on(
				"obsidian-local-rest-api:loaded",
				() => this.registerWithLocalRestApi(),
			) as never,
		);
	}

	private registerWithLocalRestApi() {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		const app = this.app as any;
		const restPlugin = app.plugins?.plugins?.["obsidian-local-rest-api"];
		const api = restPlugin?.api as LocalRestApiPublicApi | undefined;
		if (!api) return; // not loaded yet; the event above will call again.
		this.restApi = api;
		this.registerTools();
	}

	private getDataviewApi(): DataviewApi | undefined {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		const app = this.app as any;
		return app.plugins?.plugins?.["dataview"]?.api as DataviewApi | undefined;
	}

	private registerTools() {
		const api = this.restApi;
		if (!api) return;

		api.addMcpTool(
			"dataview_query",
			"Run a Dataview Query Language (DQL) query against the vault (e.g. 'LIST FROM #recipe' or 'TABLE file.mtime FROM \"notes\"') and return the result rendered as markdown.",
			{ query: z.string().describe("A DQL query string.") },
			async ({ query }) => {
				const dv = this.getDataviewApi();
				if (!dv) return { error: "Dataview plugin is not loaded." };
				try {
					const result = await dv.queryMarkdown(query as string);
					if (!result.successful) return { error: result.error };
					return { markdown: result.value };
				} catch (e) {
					return { error: e instanceof Error ? e.message : String(e) };
				}
			},
		);

		api.addMcpTool(
			"dataview_eval_js",
			"EXPERIMENTAL: evaluate a DataviewJS-like script. `dv` in scope exposes Dataview's query API " +
				"(pages, query, ...) plus render-style helpers (header/paragraph/el/list/table) that record " +
				"what they were called with instead of touching Obsidian's editor DOM, since there is no " +
				"Obsidian UI here. The script should `return` its result explicitly — a real in-app " +
				"dataviewjs block never needs to, because it renders directly in the editor pane — so " +
				"results may not exactly match what you'd see there for scripts that lean on rendering.",
			{ script: z.string().describe("JavaScript source with `dv` in scope. Should `return` a value.") },
			async ({ script }) => {
				const dv = this.getDataviewApi();
				if (!dv) return { error: "Dataview plugin is not loaded." };
				const { shim, rendered } = buildJsShim(dv);
				try {
					// eslint-disable-next-line @typescript-eslint/no-implied-eval
					const fn = new Function("dv", "dataview", `return (async () => {\n${script}\n})();`);
					const returned = await fn(shim, shim);
					return { returned: returned === undefined ? null : returned, rendered };
				} catch (e) {
					return { error: e instanceof Error ? e.stack ?? e.message : String(e), rendered };
				}
			},
		);
	}
}
