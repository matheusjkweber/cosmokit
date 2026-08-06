// Portuguese copy for the feature sections.
//
// pt-BR is the single largest source of Google traffic to this site, but the
// sitelink pages were English-only: the /recursos page had Portuguese chrome
// wrapped around English feature content. Same shape as FEATURES so the page
// components are unchanged.
import type { Feature } from "./marketing";
import { FEATURES } from "./marketing";

type LocalizedFeature = Pick<
  Feature,
  "title" | "tagline" | "description" | "bullets" | "proQualifier"
>;

const PT_BR: Record<string, LocalizedFeature> = {
  control: {
    title: "Controle do simulador",
    tagline: "Use qualquer Simulador do iOS sem o terminal",
    description:
      "Inicie, desligue, apague e gerencie todos os Simuladores do iOS em um app nativo para macOS. Chega de decorar comandos do xcrun simctl.",
    bullets: [
      "Inicie e gerencie vários simuladores lado a lado",
      "Apague, redefina e reinicie com um clique",
      "Altere aparência, barra de status e permissões",
      "Instale e abra qualquer app na hora",
    ],
  },
  capture: {
    title: "Captura e gravação de tela",
    tagline: "Screenshots e vídeo, prontos para QA e marketing",
    description:
      "Capture screenshots perfeitos e grave vídeo de qualquer simulador para relatórios de bug, materiais da App Store e marketing, direto da barra de menus.",
    bullets: [
      "Screenshots em alta resolução com um clique",
      "Gravações de tela fluidas",
      "Ideal para QA, bugs e materiais da loja",
      "Salve e compartilhe em segundos",
    ],
  },
  network: {
    title: "Proxy de rede e inspeção",
    tagline: "Veja e molde o tráfego do seu simulador",
    description:
      "Passe o tráfego do simulador pelo proxy integrado do CosmoKit para inspecionar requisições HTTPS, depurar chamadas de API e testar o app em redes instáveis.",
    bullets: [
      "Inspecione requisições e respostas HTTPS",
      "Depure integrações de API rapidamente",
      "Teste comportamento offline e em rede lenta",
      "Configuração do proxy com um clique",
    ],
    proQualifier:
      "O Proxy de Rede faz parte do CosmoKit Pro (com teste gratuito).",
  },
  push: {
    title: "Notificações push",
    tagline: "Dispare pushes de teste com um clique",
    description:
      "Envie payloads de push totalmente personalizados para o simulador e teste deep links, badges e a interface de notificação, sem backend nem aparelho físico.",
    bullets: [
      "Payloads JSON personalizados",
      "Teste toques em notificações e deep links",
      "Sem servidor nem dispositivo",
      "Modelos reutilizáveis",
    ],
  },
  location: {
    title: "Localização e simulação de GPS",
    tagline: "Coloque seu app em qualquer lugar do mundo",
    description:
      "Defina qualquer coordenada de GPS ou simule movimento para testar mapas, geofencing e recursos que dependem de localização sem sair da mesa.",
    bullets: [
      "Posicione o simulador em qualquer coordenada",
      "Teste geofencing e recursos de mapa",
      "Simule movimento e rotas",
      "Salve localizações favoritas",
    ],
  },
  deeplinks: {
    title: "Deep links",
    tagline: "Abra qualquer URL scheme na hora",
    description:
      "Dispare universal links e URL schemes personalizados diretamente, para testar roteamento e fluxos de onboarding em segundos.",
    bullets: [
      "Abra URL schemes personalizados",
      "Teste universal links",
      "Valide roteamento e onboarding",
      "Histórico de links reutilizável",
    ],
  },
};

/// FEATURES with Portuguese copy, keeping the original icon, id and path.
export const FEATURES_PT_BR: Feature[] = FEATURES.map((feature) => {
  const translated = PT_BR[feature.id];
  return translated ? { ...feature, ...translated } : feature;
});
