import React, { useState } from 'react';
import { INITIAL_RESPONSE_TASKS } from '@/data/responseTasks';
import type { ResponseTask, ResponseStatus } from '@/types/government';
import { AssignTeamModal } from '@/components/modals/AssignTeamModal';
import { SendAdvisoryModal } from '@/components/modals/SendAdvisoryModal';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import {
  ShieldAlert,
  UserCheck,
  Send,
  CheckCircle2,
  ChevronRight,
  Search,
  FileCheck2,
  FlaskConical,
  Stethoscope,
  ClipboardList,
  AlertCircle
} from 'lucide-react';

export const GovernmentResponseView: React.FC = () => {
  const [tasks, setTasks] = useState<ResponseTask[]>(INITIAL_RESPONSE_TASKS);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedPriorityFilter, setSelectedPriorityFilter] = useState('All');
  const [selectedStatusFilter, setSelectedStatusFilter] = useState('All');

  const [isAssignModalOpen, setIsAssignModalOpen] = useState(false);
  const [isAdvisoryModalOpen, setIsAdvisoryModalOpen] = useState(false);
  const [activeTask, setActiveTask] = useState<ResponseTask | null>(null);

  const handleUpdateStatus = (taskId: string, newStatus: ResponseStatus) => {
    setTasks((prev) =>
      prev.map((t) => (t.id === taskId ? { ...t, status: newStatus } : t))
    );
  };

  const filteredTasks = tasks.filter((t) => {
    const matchesSearch =
      t.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.district.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.village.toLowerCase().includes(searchQuery.toLowerCase()) ||
      t.diseaseConcern.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesPriority =
      selectedPriorityFilter === 'All' || t.priority === selectedPriorityFilter;

    const matchesStatus =
      selectedStatusFilter === 'All' || t.status === selectedStatusFilter;

    return matchesSearch && matchesPriority && matchesStatus;
  });

  const getStatusBadge = (status: ResponseStatus) => {
    switch (status) {
      case 'Completed':
        return <Badge variant="low">Completed</Badge>;
      case 'In Progress':
        return <Badge variant="secondary">In Progress</Badge>;
      case 'Awaiting Lab Result':
        return <Badge variant="moderate">Awaiting Lab Result</Badge>;
      case 'Assigned':
        return <Badge variant="outline">Assigned</Badge>;
      case 'New':
      default:
        return <Badge variant="critical">New Report</Badge>;
    }
  };

  const workflowSteps = [
    { title: 'Disease Report', subtitle: 'Farmer / Dispensary', icon: ClipboardList, active: true },
    { title: 'Risk Assessment', subtitle: 'GIS Scoring Engine', icon: AlertCircle, active: true },
    { title: 'Area Prioritized', subtitle: 'District Flagged', icon: ShieldAlert, active: true },
    { title: 'Veterinary Team Assigned', subtitle: 'RRT Mobile Unit', icon: UserCheck, active: true },
    { title: 'Field Action', subtitle: 'Quarantine & Ring Vax', icon: Stethoscope, active: true },
    { title: 'Sample / Lab Diagnosis', subtitle: 'TANUVAS / Pune Lab', icon: FlaskConical, active: true },
    { title: 'Government Review', subtitle: 'Containment Sign-off', icon: FileCheck2, active: true }
  ];

  return (
    <div className="space-y-6 animate-in fade-in-50 duration-200">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-2 border-b border-[#E4EAF0]">
        <div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-[#1769AA] uppercase tracking-wider">
              Emergency Response Directorate
            </span>
            <span className="text-xs text-[#667482]">•</span>
            <span className="text-xs text-[#667482]">Containment Operations</span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#18232B] tracking-tight">
            Government Response Center
          </h1>
          <p className="text-xs sm:text-sm text-[#667482] mt-0.5">
            Coordinate mobile veterinary squads, track sample diagnostic pipelines, and authorize field containment protocols.
          </p>
        </div>
      </div>

      {/* Visual Government Response Workflow Pipeline */}
      <Card className="border-[#E4EAF0] shadow-xs overflow-hidden">
        <CardHeader className="bg-[#F7F9FB] border-b border-[#E4EAF0] pb-3">
          <CardTitle className="text-xs font-bold text-[#12304A] uppercase tracking-wider">
            Standard State Epidemiological Response Pipeline
          </CardTitle>
        </CardHeader>
        <CardContent className="p-4 sm:p-5 overflow-x-auto">
          <div className="flex items-center justify-between min-w-[760px] gap-2">
            {workflowSteps.map((step, idx) => {
              const Icon = step.icon;
              return (
                <React.Fragment key={step.title}>
                  <div className="flex flex-col items-center text-center space-y-1.5 flex-1">
                    <div className="size-10 rounded-xl bg-[#EAF3FB] border border-[#1769AA]/20 text-[#1769AA] flex items-center justify-center shadow-xs">
                      <Icon className="size-5" />
                    </div>
                    <span className="font-bold text-xs text-[#18232B] leading-tight">
                      {step.title}
                    </span>
                    <span className="text-[10px] text-[#667482] leading-tight">
                      {step.subtitle}
                    </span>
                  </div>
                  {idx < workflowSteps.length - 1 && (
                    <div className="flex items-center justify-center px-1 text-[#CBD5E1]">
                      <ChevronRight className="size-4" />
                    </div>
                  )}
                </React.Fragment>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Filter Bar */}
      <div className="p-3 sm:p-4 rounded-xl bg-white border border-[#E4EAF0] shadow-xs space-y-3">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <div className="relative">
            <Search className="size-4 text-[#667482] absolute left-3 top-2.5" />
            <Input
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search response task or village..."
              className="pl-9 h-9 text-xs"
            />
          </div>

          <select
            value={selectedPriorityFilter}
            onChange={(e) => setSelectedPriorityFilter(e.target.value)}
            className="h-9 px-3 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
          >
            <option value="All">All Priorities (Critical, High, Medium, Monitoring)</option>
            <option value="Critical">Critical Priority Tasks</option>
            <option value="High">High Priority Tasks</option>
            <option value="Medium">Medium Priority Tasks</option>
            <option value="Monitoring">Monitoring & Verification</option>
          </select>

          <select
            value={selectedStatusFilter}
            onChange={(e) => setSelectedStatusFilter(e.target.value)}
            className="h-9 px-3 rounded-lg border border-[#E4EAF0] bg-white text-xs text-[#18232B] focus:outline-none focus:ring-2 focus:ring-[#087F73]"
          >
            <option value="All">All Task Statuses</option>
            <option value="New">New Reports</option>
            <option value="Assigned">Assigned to Team</option>
            <option value="In Progress">Field In Progress</option>
            <option value="Awaiting Lab Result">Awaiting Lab Result</option>
            <option value="Completed">Completed & Verified</option>
          </select>
        </div>
      </div>

      {/* Prioritized Task Board List */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h2 className="text-base font-bold text-[#18232B] tracking-tight">
            Field Containment Operations ({filteredTasks.length})
          </h2>
          <span className="text-xs text-[#667482]">
            Sorted by clinical urgency and SLA due dates
          </span>
        </div>

        <div className="space-y-3">
          {filteredTasks.map((task) => (
            <Card
              key={task.id}
              className="border-[#E4EAF0] shadow-xs hover:border-[#CBD5E1] transition-all"
            >
              <CardContent className="p-4 sm:p-5 space-y-3">
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-2">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2">
                      <span className="font-bold text-sm sm:text-base text-[#18232B]">
                        {task.title}
                      </span>
                      <Badge
                        variant={
                          task.priority === 'Critical'
                            ? 'critical'
                            : task.priority === 'High'
                            ? 'high'
                            : task.priority === 'Medium'
                            ? 'moderate'
                            : 'secondary'
                        }
                        className="text-[10px] py-0 px-1.5 shrink-0"
                      >
                        {task.priority}
                      </Badge>
                    </div>

                    <div className="flex flex-wrap items-center gap-3 text-xs text-[#667482]">
                      <span>
                        Target: <strong className="text-[#12304A]">{task.district} ({task.village})</strong>
                      </span>
                      <span>•</span>
                      <span>
                        Concern: <strong className="text-[#1769AA]">{task.diseaseConcern}</strong>
                      </span>
                      <span>•</span>
                      <span>
                        Due Date: <strong>{task.dueDate}</strong>
                      </span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 self-start sm:self-auto shrink-0">
                    {getStatusBadge(task.status)}
                  </div>
                </div>

                {task.notes && (
                  <p className="p-3 rounded-lg bg-[#F7F9FB] border border-[#E4EAF0] text-xs text-[#18232B] leading-relaxed">
                    <strong>Operational Log:</strong> {task.notes}
                  </p>
                )}

                {/* Team Assignment & Direct Actions Bar */}
                <div className="pt-2 border-t border-[#E4EAF0] flex flex-wrap items-center justify-between gap-2 text-xs">
                  <div className="flex items-center gap-1.5 text-[#667482]">
                    <UserCheck className="size-3.5 text-[#087F73]" />
                    <span>
                      Assigned: <strong className="text-[#18232B]">{task.assignedTeam}</strong>
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center gap-1.5">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => {
                        setActiveTask(task);
                        setIsAssignModalOpen(true);
                      }}
                      className="h-8 text-xs gap-1"
                    >
                      <UserCheck className="size-3.5" />
                      Reassign
                    </Button>

                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={() => {
                        setActiveTask(task);
                        setIsAdvisoryModalOpen(true);
                      }}
                      className="h-8 text-xs gap-1"
                    >
                      <Send className="size-3.5" />
                      Advisory
                    </Button>

                    {task.status !== 'Completed' && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleUpdateStatus(task.id, 'Completed')}
                        className="h-8 text-xs text-[#16845B] hover:bg-[#EAF7F2] gap-1"
                      >
                        <CheckCircle2 className="size-3.5" />
                        Mark Complete
                      </Button>
                    )}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Connected Modals */}
      <AssignTeamModal
        isOpen={isAssignModalOpen}
        onClose={() => setIsAssignModalOpen(false)}
        districtName={activeTask?.district || 'Nagpur'}
        taskTitle={activeTask?.title || 'Emergency Taskforce Deployment'}
        onAssigned={(teamName) => {
          if (activeTask) {
            setTasks((prev) =>
              prev.map((t) =>
                t.id === activeTask.id ? { ...t, assignedTeam: teamName, status: 'In Progress' } : t
              )
            );
          }
        }}
      />

      <SendAdvisoryModal
        isOpen={isAdvisoryModalOpen}
        onClose={() => setIsAdvisoryModalOpen(false)}
        districtName={activeTask?.district || 'Nagpur'}
        diseaseName={activeTask?.diseaseConcern || 'Foot-and-Mouth Disease'}
        onSent={() => {}}
      />
    </div>
  );
};
