import React, { useState } from 'react';
import { Button } from '@/components/ui/button';
import { X, Send, BellRing, Check } from 'lucide-react';

interface SendAdvisoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  districtName?: string;
  diseaseName?: string;
  onSent?: () => void;
}

export const SendAdvisoryModal: React.FC<SendAdvisoryModalProps> = ({
  isOpen,
  onClose,
  districtName = 'Pune',
  diseaseName = 'Foot-and-Mouth Disease (FMD)',
  onSent
}) => {
  const [channels, setChannels] = useState({
    sms: true,
    sarpanchNet: true,
    dairyCoops: true,
    vetApp: true
  });
  const [advisoryContent, setAdvisoryContent] = useState(
    `GOVT HEALTH ADVISORY (${districtName}): Heightened risk of ${diseaseName} detected. Farmers are advised to restrict animal trade transit, isolate animals exhibiting fever or salivation, and report immediately to nearest Veterinary Dispensary.`
  );
  const [isDispatched, setIsDispatched] = useState(false);

  if (!isOpen) return null;

  const handleSend = () => {
    setIsDispatched(true);
    setTimeout(() => {
      setIsDispatched(false);
      if (onSent) onSent();
      onClose();
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-[#12304A]/60 backdrop-blur-xs animate-in fade-in-0">
      <div className="bg-white rounded-2xl border border-[#E4EAF0] shadow-2xl w-full max-w-lg overflow-hidden flex flex-col">
        <div className="px-6 py-4 border-b border-[#E4EAF0] flex items-center justify-between bg-[#F7F9FB]">
          <div className="flex items-center gap-2">
            <div className="size-8 rounded-lg bg-[#FFF5D6] text-[#B87A04] flex items-center justify-center">
              <BellRing className="size-4" />
            </div>
            <div>
              <h2 className="text-base font-bold text-[#18232B] tracking-tight">
                Broadcast Government Advisory
              </h2>
              <span className="text-xs text-[#667482]">Target Zone: {districtName} Talukas & Cooperatives</span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="size-8 rounded-lg text-[#667482] hover:text-[#18232B] hover:bg-[#E4EAF0] flex items-center justify-center transition-colors cursor-pointer"
          >
            <X className="size-4" />
          </button>
        </div>

        <div className="p-6 space-y-4 text-xs">
          <div>
            <label className="font-semibold text-[#18232B] block mb-2">
              Dissemination Channels
            </label>
            <div className="grid grid-cols-2 gap-2">
              {[
                { key: 'sms', label: 'Farmer SMS Network (State Telephony)' },
                { key: 'sarpanchNet', label: 'Gram Panchayat Sarpanch Portal' },
                { key: 'dairyCoops', label: 'Dairy Co-operative Chilling Hubs' },
                { key: 'vetApp', label: 'Pashu Seva Veterinarian Mobile App' }
              ].map((c) => (
                <label
                  key={c.key}
                  className={`p-2.5 rounded-lg border flex items-center gap-2 cursor-pointer transition-colors ${
                    (channels as any)[c.key]
                      ? 'border-[#1769AA] bg-[#EAF3FB]/70 text-[#12304A] font-semibold'
                      : 'border-[#E4EAF0] text-[#667482]'
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={(channels as any)[c.key]}
                    onChange={(e) =>
                      setChannels((prev) => ({ ...prev, [c.key]: e.target.checked }))
                    }
                    className="rounded text-[#087F73] focus:ring-[#087F73]"
                  />
                  <span className="text-[11px] leading-tight">{c.label}</span>
                </label>
              ))}
            </div>
          </div>

          <div>
            <label className="font-semibold text-[#18232B] block mb-1.5">
              Official Advisory Bulletin Text
            </label>
            <textarea
              rows={4}
              value={advisoryContent}
              onChange={(e) => setAdvisoryContent(e.target.value)}
              className="w-full p-3 rounded-lg border border-[#E4EAF0] bg-[#F7F9FB] text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73] leading-relaxed resize-none"
            />
          </div>

          <div className="p-3 rounded-lg bg-[#EAF7F2] border border-[#16845B]/20 text-xs text-[#16845B]">
            Estimated audience: <strong>14,200 registered livestock owners</strong> across {districtName}.
          </div>
        </div>

        <div className="px-6 py-4 border-t border-[#E4EAF0] flex items-center justify-end gap-2 bg-[#F7F9FB]">
          <Button variant="ghost" size="sm" onClick={onClose}>
            Cancel
          </Button>
          <Button
            variant="default"
            size="sm"
            onClick={handleSend}
            disabled={isDispatched}
            className="gap-1.5 bg-[#12304A]"
          >
            {isDispatched ? (
              <>
                <Check className="size-4 text-emerald-400" />
                Broadcasting...
              </>
            ) : (
              <>
                <Send className="size-4" />
                Dispatch Advisory
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  );
};
