export const buildSmsLink = (message: string) => {
  const encoded = encodeURIComponent(message);
  return `sms:?&body=${encoded}`;
};

export const canUseSms = () => {
  if (typeof navigator === 'undefined') return false;
  return /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
};
